//
//  BusinessCell.swift
//  Yelp
//
//  Created by Patwardhan, Saurabh on 10/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var business : Business! {
        didSet{
            nameLabel.text = business.name
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
            distanceLabel.text = business.distance
            ratingImageView.setImageWith(business.ratingImageURL!)
            
            if business.imageURL != nil {
                let imageUrlRequest = URLRequest(url: business.imageURL!)
                
                thumbImageView.setImageWith(imageUrlRequest, placeholderImage: nil,
                                             success: { (request : URLRequest, response : HTTPURLResponse?, image : UIImage!) in
                    if image != nil {
                        self.thumbImageView.alpha = 0
                        self.thumbImageView.image = image
                        UIView.animate(withDuration: 0.5 , animations: {() -> Void in
                            self.thumbImageView.alpha = 1
                        })
                    }
                    
                    }, failure: { (request : URLRequest,response : HTTPURLResponse?,error : Error) -> Void in
                        self.thumbImageView.image = #imageLiteral(resourceName: "no-image-found")
                })
            } else {
                self.thumbImageView.image = #imageLiteral(resourceName: "no-image-found")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        
        // nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
