import UIKit

class TypeSelectorCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.indicatorView.alpha = self.isSelected ? 1.0 : 0.0
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = self.isHighlighted ? UIColor.init(white: 0.9, alpha: 1.0) : UIColor.white
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        self.titleLabel.text = ""
        self.indicatorView.alpha = 0.0
    }
}
