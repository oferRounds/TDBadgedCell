//
//  TDBadgedCell.swift
//  TDBadgedCell
//
//  Created by Tim Davies on 07/09/2016.
//  Copyright © 2016 Tim Davies. All rights reserved.
//

import UIKit

/// TDBadgedCell is a table view cell class that adds a badge, similar to the badges in Apple's own apps
/// The badge is generated as image data and drawn as a sub view to the table view sell. This is hopefully
/// most resource effective that a manual draw(rect:) call would be
@objc public class TDBadgedCell: UITableViewCell {

    /// Badge value
    public var badgeString : String = "" {
        didSet {
            if(badgeString == "") {
                badgeView.removeFromSuperview()
                layoutSubviews()
            } else {
                contentView.addSubview(badgeView)
                drawBadge()
            }
        }
    }
    
    /// Badge background color for normal states
    public var badgeColor : UIColor = UIColor(red: 1.0, green: 81.0/255.0, blue: 0.0, alpha: 1.0)
    /// Badge background color for highlighted states
    public var badgeColorHighlighted : UIColor = UIColor.darkGrayColor()
    
    /// Badge font size
    public var badgeFontSize : Float = 14.0
    /// Badge text color
    public var badgeTextColor: UIColor?
    /// Corner radius of the badge. Set to 0 for square corners.
    public var badgeRadius : Float = 20
    /// The Badges offset from the right hand side of the Table View Cell
    public var badgeOffset = CGPoint(x:20, y:0)
    
    /// The Image view that the badge will be rendered into
    internal let badgeView = UIImageView()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout our badge's position
        var offsetX = badgeOffset.x
        if(editing == false && accessoryType != .None || (accessoryView) != nil) {
            offsetX = 0 // Accessory types are a pain to get sizing for?
        }
        
        badgeView.frame.origin.x = floor(contentView.frame.width - badgeView.frame.width - offsetX)
        badgeView.frame.origin.y = floor((frame.height / 2) - (badgeView.frame.height / 2))
        
        // Now lets update the width of the cells text labels to take the badge into account
        textLabel?.frame.size.width -= badgeView.frame.width + (offsetX * 2)
        if((detailTextLabel) != nil) {
            detailTextLabel?.frame.size.width -= badgeView.frame.width + (offsetX * 2)
        }
    }
    
    // When the badge
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        drawBadge()
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        drawBadge()
    }
    
    /// Generate the badge image
    internal func drawBadge() {
        // Calculate the size of our string
        let textSize : CGSize = NSString(string: badgeString).sizeWithAttributes([NSFontAttributeName:UIFont.boldSystemFontOfSize(CGFloat(badgeFontSize))])
        
        // Create a frame with padding for our badge
        let height = textSize.height + 5
        var width = textSize.width + 16
        if(width < height) {
            width = height
        }
        
        let badgeFrame : CGRect = CGRect(x:0, y:0, width:width, height:height)
        
        let badge = CALayer()
        badge.frame = badgeFrame
        
        if(highlighted || selected) {
            badge.backgroundColor = badgeColorHighlighted.CGColor
        } else {
            badge.backgroundColor = UIColor(red: 1.0, green: 81.0/255.0, blue: 0.0, alpha: 1.0).CGColor
        }

        badge.cornerRadius = (CGFloat(badgeRadius) < (badge.frame.size.height / 2)) ? CGFloat(badgeRadius) : CGFloat(badge.frame.size.height / 2)
        
        // Draw badge into graphics context
        UIGraphicsBeginImageContextWithOptions(badge.frame.size, false, UIScreen.mainScreen().scale)
        let ctx = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(ctx)
        badge.renderInContext(ctx)
        CGContextSaveGState(ctx)
        
        // Draw string into graphics context
        if(badgeTextColor == nil) {
            CGContextSetBlendMode(ctx, .Clear)
        }
        
        NSString(string: badgeString).drawInRect(CGRectMake(8, 2, textSize.width, textSize.height), withAttributes: [
            NSFontAttributeName:UIFont.boldSystemFontOfSize(CGFloat(badgeFontSize)),
            NSForegroundColorAttributeName: badgeTextColor ?? UIColor.clearColor()
        ])
        
        let badgeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        badgeView.frame = CGRect(x:0, y:0, width:badgeImage.size.width, height:badgeImage.size.height)
        badgeView.image = badgeImage
        
        layoutSubviews()
    }
}
