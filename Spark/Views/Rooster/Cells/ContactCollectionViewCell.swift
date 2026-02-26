import UIKit
import SkeletonView

class ContactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
    }
    
    func configure(with contact: Contact) {
        nameLabel.text = contact.name
        
        if let url = URL(string: contact.image) {
            ImageLoader.shared.load(url: url, into: imageView)
        } else {
            imageView.image = UIImage(systemName: "person.fill")
        }
    }
}
