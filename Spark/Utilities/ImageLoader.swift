import Foundation
import UIKit

final class ImageLoader {
    
    static let shared = ImageLoader()
    private var cache = NSCache<NSURL, UIImage>()
    
    func load(url: URL, into imageView: UIImageView) {
        
        if let cached = cache.object(forKey: url as NSURL) {
            imageView.image = cached
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }
            
            self.cache.setObject(image, forKey: url as NSURL)
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}
