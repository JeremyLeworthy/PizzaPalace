//
//  ViewController.swift
//  PizzaPalace
//
//  Created by Jeremy Leworthy on 2020-10-05.
//

import UIKit

var profileList: [Profile] = []
var currentOrder: [RegularPizza] = []
var orderHistory: [OrderHistoryEntry] = []

func sizePriceAdjustment(pizza: RegularPizza) -> Double {
    switch pizza.size {
        case 1:
            return 2
        case 2:
            return 4
        case 3:
            return 6
        default:
            return 0
        }
}

class TabBarController: UITabBarController {
    @objc private func showOrders() {
        self.selectedIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 1
        NotificationCenter.default.addObserver(self, selector: #selector(showOrders), name: Notification.Name("showOrders"), object: nil)
    }
}

class MenuItemCell: UITableViewCell {
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var title: UILabel!
}

class MenuItem {
    var imgName: String
    var price: Double
    var name: String
    
    init(imgName: String, price: Double, name: String) {
        self.imgName = imgName
        self.price = price
        self.name = name
    }
}

class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var btnCheckout: UIButton!
    
    var menu: [MenuItem] = []
    var currentTotal: Double = 0
    
    @IBAction func checkout(_ sender: UIButton) {
        if currentTotal > 0 {
            performSegue(withIdentifier: "checkoutSegue", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell", for: indexPath) as! MenuItemCell
        for i in 0 ... menu.count - 1 {
            if indexPath.row == i {
                cell.imgItem.image = UIImage(named: menu[i].imgName)
                cell.price.text = "$\(menu[i].price) +"
                cell.title.text = menu[i].name
                return cell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 6 {
            performSegue(withIdentifier: "pizzaSegue", sender: menu[indexPath.row])
        } else {
            performSegue(withIdentifier: "customPizzaSegue", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func createMenu() -> [MenuItem] {
        return [MenuItem(imgName: "", price: 7.99, name: "Pepperoni"),
                MenuItem(imgName: "", price: 6.99, name: "Cheese"),
                MenuItem(imgName: "", price: 7.99, name: "Deluxe"),
                MenuItem(imgName: "", price: 7.99, name: "Hawaiian"),
                MenuItem(imgName: "", price: 8.99, name: "Meat"),
                MenuItem(imgName: "", price: 6.99, name: "Veggie"),
                MenuItem(imgName: "", price: 8.99, name: "Build your own")]
    }
    
    @objc private func calculateTotal() {
        currentTotal = 0
        if currentOrder.count > 0 {
            for item in currentOrder {
                currentTotal += (item.basePrice + sizePriceAdjustment(pizza: item)) * Double(item.quantity)
            }
            let currentTotalString = String(format: "%.2f", currentTotal)
            btnCheckout.setTitle("Checkout - $" + currentTotalString, for: .normal)
        } else {
            btnCheckout.setTitle("Checkout", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menu = createMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(calculateTotal), name: Notification.Name("updateCart"), object: nil)
        profileList.append(Profile(pName: "Add payment profile", email: "", phone: "", address: "", city: "", prov: "", postal: "", cName: "", cNum: "", security: "", expiry: ""))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let regularPizza = segue.destination as? RegularPizzaViewController {
            regularPizza.selectedPizza = sender as? MenuItem
        }
    }
}

class RegularPizza {
    var size: Int
    var crust: Int
    var sauce: Int
    var quantity: Int
    var basePrice: Double
    var title: String
    
    init(size: Int, crust: Int, sauce: Int, quantity: Int, basePrice: Double, title: String) {
        self.size = size
        self.crust = crust
        self.sauce = sauce
        self.quantity = quantity
        self.basePrice = basePrice
        self.title = title
    }
}

class RegularPizzaViewController: UIViewController {
    @IBOutlet weak var sizeControl: UISegmentedControl!
    @IBOutlet weak var crustControl: UISegmentedControl!
    @IBOutlet weak var sauceControl: UISegmentedControl!
    @IBOutlet weak var txtQuantity: UITextField!
    
    var selectedPizza: MenuItem!
    var quantity = 1
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        let pizza = RegularPizza(size: sizeControl.selectedSegmentIndex, crust: crustControl.selectedSegmentIndex, sauce: sauceControl.selectedSegmentIndex, quantity: quantity, basePrice: selectedPizza.price, title: selectedPizza.name)
        currentOrder.append(pizza)
        NotificationCenter.default.post(name: Notification.Name("updateCart"), object: nil)
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func adjustQuantity(_ sender: UIButton) {
        if sender.accessibilityIdentifier == "inc" {
            quantity += 1
        } else {
            if quantity > 1 {
                quantity -= 1
            }
        }
        txtQuantity.text = "\(quantity)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtQuantity.text = "\(quantity)"
    }
}

class customPizza: RegularPizza {
    var toppings: [String]
    
    init(toppings: [String], size: Int, crust: Int, sauce: Int, quantity: Int, basePrice: Double) {
        self.toppings = toppings
        super.init(size: size, crust: crust, sauce: sauce, quantity: quantity, basePrice: basePrice, title: "Custom Pizza")
    }
}

class CustomPizzaViewController: UIViewController {
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class OrderSummaryCell: UITableViewCell {
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var quantity: UILabel!
}

class OrderSummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet weak var txtSubtotal: UITextField!
    @IBOutlet weak var txtTax: UITextField!
    @IBOutlet weak var txtTip: UITextField!
    @IBOutlet weak var txtTotal: UITextField!
    @IBOutlet weak var profilePicker: UIPickerView!
    @IBOutlet weak var btnOrder: UIButton!
    
    var currentTotal: Double = 0
    var currentTip: Double = 0
    var currentTax: Double = 0
    
    var tap: UIGestureRecognizer!
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func placeOrder(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let currentTime = formatter.string(from: Date())
        let newOrder = OrderHistoryEntry(purchasedBy: profileList[profilePicker.selectedRow(inComponent: 0)].profileName, orderTotal: currentTotal + currentTax, timePlaced: currentTime, orderDetails: currentOrder)
        orderHistory.insert(newOrder, at: 0)
        currentTotal = 0
        currentTax = 0
        currentTip = 0
        currentOrder.removeAll()
        NotificationCenter.default.post(name: Notification.Name("updateCart"), object: nil)
        dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name("showOrders"), object: nil)
        })
    }
    
    @IBAction func tip(_ sender: UITextField) {
        let tip = Double(txtTip.text!)
        if tip != nil && tip! > 0 {
            currentTotal += tip!
            currentTip = tip!
            let total = currentTotal + currentTax
            let totalString = String(format: "%.2f", (total))
            txtTotal.text = "$" + totalString
        } else {
            currentTotal -= currentTip
            currentTip = 0
            let total = currentTotal + currentTax
            let totalString = String(format: "%.2f", (total))
            txtTotal.text = "$" + totalString
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderSummaryCell", for: indexPath) as! OrderSummaryCell
        for i in 0 ... currentOrder.count - 1 {
            if indexPath.row == i {
                cell.title.text = currentOrder[i].title
                cell.desc.text = getPizzaDescription(pizza: currentOrder[i])
                cell.quantity.text = "\(currentOrder[i].quantity) x $\(currentOrder[i].basePrice + sizePriceAdjustment(pizza: currentOrder[i]))"
                let currentTotalString = String(format: "%.2f", (currentOrder[i].basePrice + sizePriceAdjustment(pizza: currentOrder[i])) * Double(currentOrder[i].quantity))
                cell.totalPrice.text = "$" + currentTotalString
                return cell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentOrder.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            setCosts()
            NotificationCenter.default.post(name: Notification.Name("updateCart"), object: nil)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if profileList.count > 0 {
            return profileList.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if profileList.count > 0 {
            return profileList[row].profileName
        } else {
            return "Add payment profile"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Update payment")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func getPizzaDescription(pizza: RegularPizza) -> String {
        var currentDescription = ""
        
        switch pizza.size {
            case 1:
                currentDescription.append("(M) ")
            case 2:
                currentDescription.append("(L) ")
            case 3:
                currentDescription.append("(XL) ")
            default:
                currentDescription.append("(S) ")
        }
    
        switch pizza.crust {
            case 1:
                currentDescription.append("Thin Crust ")
            default:
                currentDescription.append("Regular Crust ")
        }
        
        switch pizza.sauce {
            case 1:
                currentDescription.append("BBQ Sauce")
            default:
                currentDescription.append("Original Sauce")
        }
        
        return currentDescription
    }
    
    func setCosts() {
        currentTotal = 0
        currentTax = 0
        currentTip = 0
        for item in currentOrder {
            currentTotal += (item.basePrice + sizePriceAdjustment(pizza: item)) * Double(item.quantity)
        }
        let currentTotalString = String(format: "%.2f", (currentTotal))
        txtSubtotal.text = currentTotalString
        let tax = (1.13 * currentTotal) - currentTotal
        currentTax = tax
        let taxString = String(format: "%.2f", (tax))
        txtTax.text = taxString
        txtTip.text = "0"
        let total = currentTotal + tax
        let totalString = String(format: "%.2f", (total))
        txtTotal.text = "$" + totalString
    }
    
    @objc private func profilePickerTapped() {
        performSegue(withIdentifier: "addProfileSegue", sender: nil)
    }
    
    @objc private func updateProfilePicker() {
        profilePicker.reloadAllComponents()
        if profileList.count > 1 {
            btnOrder.alpha = 1
            btnOrder.isEnabled = true
            profilePicker.removeGestureRecognizer(tap)
        }
        profilePicker.selectRow(1, inComponent: 0, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCosts()
        tap = UITapGestureRecognizer(target: self, action: #selector(profilePickerTapped))
        tap.delegate = self
        profilePicker.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfilePicker), name: Notification.Name("updateProfilePicker"), object: nil)
        if profileList.count == 1 {
            btnOrder.alpha = 0.4
            btnOrder.isEnabled = false
        } else if profileList.count > 1 {
            btnOrder.alpha = 1
            btnOrder.isEnabled = true
            profilePicker.removeGestureRecognizer(tap)
            profilePicker.selectRow(1, inComponent: 0, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profilePopup = segue.destination as? ProfileViewController {
            profilePopup.newProfileFromCheckout = true
        }
    }
}

class OrderHistoryEntryCell: UITableViewCell {
    @IBOutlet weak var orderTotal: UILabel!
    @IBOutlet weak var timePlaced: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
}

class OrderHistoryEntry {
    let purchasedBy: String
    let orderTotal: Double
    let timePlaced: String
    let orderDetails: [RegularPizza]
    
    init(purchasedBy: String, orderTotal: Double, timePlaced: String, orderDetails: [RegularPizza]) {
        self.purchasedBy = purchasedBy
        self.orderTotal = orderTotal
        self.timePlaced = timePlaced
        self.orderDetails = orderDetails
    }
}

class InfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tblOrderHistory: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderHistoryEntryCell", for: indexPath) as! OrderHistoryEntryCell
        for i in 0 ... orderHistory.count - 1 {
            if indexPath.row == i {
                let orderTotalString = String(format: "%.2f", (orderHistory[i].orderTotal))
                cell.orderTotal.text = "$" + orderTotalString
                cell.timePlaced.text = orderHistory[i].timePlaced
                cell.imgStatus.image = UIImage(named: "")
                return cell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tblOrderHistory.reloadData()
    }
}

class Profile {
    var profileName: String
    var email: String
    var phone: String
    var address: String
    var city: String
    var province: String
    var postalCode: String
    var creditName: String
    var creditNumber: String
    var creditSecurity: String
    var creditExpiration: String
    
    init(pName: String, email: String, phone: String, address: String, city: String, prov: String, postal: String, cName: String, cNum: String, security: String, expiry: String) {
        self.profileName = pName
        self.email = email
        self.phone = phone
        self.address = address
        self.city = city
        self.province = prov
        self.postalCode = postal
        self.creditName = cName
        self.creditNumber = cNum
        self.creditSecurity = security
        self.creditExpiration = expiry
    }
}

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var profilePicker: UIPickerView!
    @IBOutlet weak var txtProfileName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtProvince: UITextField!
    @IBOutlet weak var txtPostalCode: UITextField!
    @IBOutlet weak var txtCreditName: UITextField!
    @IBOutlet weak var txtCreditNumber: UITextField!
    @IBOutlet weak var txtCreditSecurity: UITextField!
    @IBOutlet weak var txtCreditExpiry: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var newProfileFromCheckout = false
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return profileList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return profileList[row].profileName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Update form")
    }
    
    @IBAction func checkTextfields(_ sender: UITextField) {
        let profileForm: [UITextField] = [txtProfileName, txtEmail, txtPhone, txtAddress, txtCity, txtProvince, txtPostalCode, txtCreditName, txtCreditNumber, txtCreditSecurity, txtCreditExpiry]
        var emptyFieldCount = 0
        for textField in profileForm {
            if !textField.hasText {
                emptyFieldCount += 1
            }
        }
        if emptyFieldCount == 0 {
            btnSave.isEnabled = true
            btnSave.alpha = 1
        } else {
            btnSave.isEnabled = false
            btnSave.alpha = 0.4
        }
    }
    
    @IBAction func saveProfile(_ sender: UIButton) {
        let newProfile = Profile(pName: txtProfileName.text!, email: txtEmail.text!, phone: txtPhone.text!, address: txtAddress.text!, city: txtCity.text!, prov: txtProvince.text!, postal: txtPostalCode.text!, cName: txtCreditName.text!, cNum: txtCreditNumber.text!, security: txtCreditSecurity.text!, expiry: txtCreditExpiry.text!)
        profileList.append(newProfile)
        profilePicker.reloadAllComponents()
        profilePicker.selectRow(profileList.count-1, inComponent: 0, animated: true)
        if newProfileFromCheckout {
            dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name("updateProfilePicker"), object: nil)
            })
        }
    }
    
    @objc private func updateProfilePicker() {
        profilePicker.reloadAllComponents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSave.isEnabled = false
        btnSave.alpha = 0.4
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfilePicker), name: Notification.Name("updateProfilePicker"), object: nil)
    }
}

