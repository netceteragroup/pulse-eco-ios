import UIKit

let cellTitleLabelFont = UIFont(name: "TitilliumWeb-Regular", size: 14)

protocol TypeSelectorViewControllerDelegate: class {
    func didSelect(measureId: String)
}

class TypeSelectorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: TypeSelectorViewControllerDelegate?
    private var sharedDataProvider = SharedDataProvider.sharedInstance

    var measureValues: [MeasureValue] = [] { // rename to measures
        didSet {
            collectionView?.reloadData()
        }
    }
    var currentMeasureId: String {
        get {
            sharedDataProvider.selectedMeasureId
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var currentMeasureValue: MeasureValue {
        get {
            return measureValues.first { $0.id == currentMeasureId }!
        }
    }

    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return measureValues.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeSelectorCell",
                                                      for: indexPath) as! TypeSelectorCell
        let measureValue = measureValues[indexPath.item]
        cell.titleLabel.text = measureValue.measure.buttonTitle
        cell.isSelected = measureValue.id == currentMeasureId
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = measureValues[indexPath.item].measure.id

        let initialSize = CGSize(width: 500, height: collectionView.frame.height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: cellTitleLabelFont]

        let estimatedRect = NSString.init(string: title).boundingRect(with: initialSize,
                                                                      options: options,
                                                                      attributes: attributes as [NSAttributedString.Key: Any],
                                                                      context: nil)
        return CGSize.init(width: estimatedRect.width + 20, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sharedDataProvider.selectedMeasureId = measureValues[indexPath.item].measure.id
        collectionView.reloadData()

        delegate?.didSelect(measureId: currentMeasureId)
    }
}
