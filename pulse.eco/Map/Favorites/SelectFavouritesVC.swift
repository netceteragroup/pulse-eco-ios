import UIKit

class SelectFavouritesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoViewHeightConstraint: NSLayoutConstraint!

    var selectedCity: City?
    var animationCompleted = true

    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.layer.zPosition = 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
//        return selectedCity?.sensors.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SelectFavoritesTableViewCell
        let colorIndex = indexPath.row % AppColors.allColors.count
        cell.colorBox.backgroundColor = AppColors.allColors[colorIndex]
        cell.nameLabel.text = "NE RABOTI"
//        cell.nameLabel.text = selectedCity?.sensors[indexPath.row].description

//        let sensorId = selectedCity!.sensors[indexPath.row].id
//        if FavouritesProvider.shared.favorites(forCity: selectedCity!.name).contains(sensorId) {
//            cell.selectionImage.image = UIImage(named: "selectFavoritesFull")
//        } else {
//            cell.selectionImage.image = UIImage(named: "selectFavoritesEmpty")
//        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let sensorId = selectedCity!.sensors[indexPath.row].id
//        if FavouritesProvider.shared.favorites(forCity: selectedCity!.name).contains(sensorId) {
//            FavouritesProvider.shared.remove(favorite: sensorId, forCity: selectedCity!.name)
//        } else {
//            if FavouritesProvider.shared.favorites(forCity: selectedCity!.name).count >= 5 {
//                showInfoView()
//            } else {
//                FavouritesProvider.shared.add(favorite: sensorId, forCity: selectedCity!.name)
//            }
//        }
//        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func showInfoView() {
        if !animationCompleted {
            return
        }
        animationCompleted = false
        self.infoView.setNeedsLayout()
        self.infoView.isHidden = false
        UIView.animate(withDuration: 0.3,
                       delay: 0, options: .curveLinear,
                       animations: {[weak self] in
                        self?.infoViewTopConstraint.constant = 0
                        self?.view.layoutIfNeeded()
        })
        hideInfoView()
    }

    private func hideInfoView() {
        self.infoView.setNeedsLayout()
        UIView.animate(withDuration: 0.3,
                       delay: 4,
                       options: .curveLinear,
                       animations: { [weak self] in
            self?.infoViewTopConstraint.constant = -40
            self?.view.layoutIfNeeded()
        }, completion: { _ in
            self.animationCompleted = true
            self.infoView.isHidden = true
        })
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

class SelectFavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var colorBox: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!

}
