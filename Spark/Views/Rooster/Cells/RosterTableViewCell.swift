import UIKit
import SkeletonView

class RosterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private var contacts: [Contact] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        setupCellAppearance()
    }
    
    private func setupCellAppearance() {
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true
    }
    
    private func setupCollectionView() {
        
        let nib = UINib(nibName: "ContactCollectionViewCell", bundle: nil)
        collectionView.register(nib,
                                forCellWithReuseIdentifier: "ContactCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 20
        }
    }
    
    func configure(with roster: Roster) {
        titleLabel.text = roster.classRosterName
        timeLabel.text = roster.timeRangeString
        contacts = roster.registeredContacts
        
        collectionView.reloadData()
        
        let cellHeight: CGFloat = 130
        
        if contacts.count > 20 {
            collectionViewHeightConstraint.constant = cellHeight * 2
        } else {
            collectionViewHeightConstraint.constant = cellHeight
        }
    }
}

extension RosterTableViewCell: SkeletonCollectionViewDataSource {

    func collectionSkeletonView(_ skeletonView: UICollectionView,
                                numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView,
                                cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ContactCollectionViewCell"
    }
}

extension RosterTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ContactCollectionViewCell",
            for: indexPath
        ) as? ContactCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: contacts[indexPath.item])
        return cell
    }
}

extension RosterTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 70, height: 110)
    }
}
