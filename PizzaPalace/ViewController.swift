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
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imgItem: UIImageView!
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
    @IBOutlet weak var tblMenu: UITableView!
    
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
        return [MenuItem(imgName: "pepperoni", price: 7.99, name: "Pepperoni"),
                MenuItem(imgName: "cheese", price: 6.99, name: "Cheese"),
                MenuItem(imgName: "deluxe", price: 7.99, name: "Deluxe"),
                MenuItem(imgName: "hawaiian", price: 7.99, name: "Hawaiian"),
                MenuItem(imgName: "meat", price: 8.99, name: "Meat"),
                MenuItem(imgName: "veggie", price: 6.99, name: "Veggie"),
                MenuItem(imgName: "custom", price: 8.99, name: "Build your own")]
    }
    
    @objc private func calculateTotal() {
        currentTotal = 0
        if currentOrder.count > 0 {
            for item in currentOrder {
                currentTotal += (item.basePrice + sizePriceAdjustment(pizza: item)) * Double(item.quantity)
            }
            let currentTotalString = String(format: "%.2f", currentTotal)
            btnCheckout.setTitle("Checkout - $" + currentTotalString, for: .normal)
            btnCheckout.alpha = 1
            btnCheckout.isEnabled = true
        } else {
            btnCheckout.setTitle("Checkout", for: .normal)
            btnCheckout.alpha = 0.4
            btnCheckout.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderHistory.append(OrderHistoryEntry(purchasedBy: "Buddy", orderTotal: 24.54, timePlaced: "10/2/20, 4:25 PM", orderDetails: [RegularPizza(size: 0, crust: 0, sauce: 0, quantity: 0, basePrice: 8.99, title: "Meat")], isComplete: true))
        tblMenu.layer.cornerRadius = 12
        btnCheckout.layer.cornerRadius = 12
        btnCheckout.alpha = 0.4
        btnCheckout.isEnabled = false
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
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnDecrease: UIButton!
    @IBOutlet weak var btnIncrease: UIButton!
    @IBOutlet weak var pizzaTitle: UILabel!
    @IBOutlet weak var pizzaImage: UIImageView!
    
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
        btnAdd.layer.cornerRadius = 12
        btnDecrease.layer.cornerRadius = 12
        btnIncrease.layer.cornerRadius = 12
        txtQuantity.text = "\(quantity)"
        pizzaTitle.text = selectedPizza.name
        pizzaImage.image = UIImage(named: selectedPizza.imgName)
        
    }
}

class CustomPizza: RegularPizza {
    var toppings: [String]
    
    init(toppings: [String], size: Int, crust: Int, sauce: Int, quantity: Int, basePrice: Double) {
        self.toppings = toppings
        super.init(size: size, crust: crust, sauce: sauce, quantity: quantity, basePrice: basePrice, title: "Custom Pizza")
    }
}

class ToppingCell: UITableViewCell {
    @IBOutlet weak var topping: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
}

class Topping {
    let name: String
    var status: Bool
    
    init(name: String, status: Bool) {
        self.name = name
        self.status = status
    }
}

class CustomPizzaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var sizeControl: UISegmentedControl!
    @IBOutlet weak var crustControl: UISegmentedControl!
    @IBOutlet weak var sauceControl: UISegmentedControl!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnDecrease: UIButton!
    @IBOutlet weak var btnIncrease: UIButton!
    @IBOutlet weak var tblToppings: UITableView!
    
    var toppings: [Topping] = []
    var quantity = 1
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        let pizza = CustomPizza(toppings: [], size: sizeControl.selectedSegmentIndex, crust: crustControl.selectedSegmentIndex, sauce: sauceControl.selectedSegmentIndex, quantity: quantity, basePrice: 8.99)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toppings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toppingCell", for: indexPath) as! ToppingCell
        for i in 0 ... toppings.count - 1 {
            if indexPath.row == i {
                cell.topping.text = toppings[i].name
                if toppings[i].status {
                    cell.imgStatus.image = UIImage(named: "checked")
                } else {
                    cell.imgStatus.image = UIImage(named: "unchecked")
                }
                return cell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toppings[indexPath.row].status = !toppings[indexPath.row].status
        tblToppings.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func createToppings() -> [Topping] {
        let t1 = Topping(name: "Pepperoni", status: false)
        let t2 = Topping(name: "Bacon", status: false)
        let t3 = Topping(name: "Sausage", status: false)
        let t4 = Topping(name: "Chicken", status: false)
        let t5 = Topping(name: "Pepper", status: false)
        let t6 = Topping(name: "Pineapple", status: false)
        let t7 = Topping(name: "Mushroom", status: false)
        let t8 = Topping(name: "Onion", status: false)
        let t9 = Topping(name: "Extra Cheese", status: false)
        return [t1, t2, t3, t4, t5, t6, t7, t8, t9]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAdd.layer.cornerRadius = 12
        btnDecrease.layer.cornerRadius = 12
        btnIncrease.layer.cornerRadius = 12
        tblToppings.layer.cornerRadius = 12
        toppings = createToppings()
        txtQuantity.text = "\(quantity)"
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
    @IBOutlet weak var tblOrderSummary: UITableView!
    
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
        let newOrder = OrderHistoryEntry(purchasedBy: profileList[profilePicker.selectedRow(inComponent: 0)].profileName, orderTotal: currentTotal + currentTax, timePlaced: currentTime, orderDetails: currentOrder, isComplete: false)
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
        tblOrderSummary.layer.cornerRadius = 12
        profilePicker.layer.cornerRadius = 12
        btnOrder.layer.cornerRadius = 12
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
    var isComplete: Bool
    
    init(purchasedBy: String, orderTotal: Double, timePlaced: String, orderDetails: [RegularPizza], isComplete: Bool) {
        self.purchasedBy = purchasedBy
        self.orderTotal = orderTotal
        self.timePlaced = timePlaced
        self.orderDetails = orderDetails
        self.isComplete = isComplete
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
                if orderHistory[i].isComplete {
                    cell.imgStatus.image = UIImage(named: "checked")
                } else {
                    cell.imgStatus.image = UIImage(named: "pending")
                }
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
        tblOrderHistory.layer.cornerRadius = 12
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
        btnSave.layer.cornerRadius = 12
        profilePicker.layer.cornerRadius = 12
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfilePicker), name: Notification.Name("updateProfilePicker"), object: nil)
    }
}

