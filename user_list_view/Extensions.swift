//
//  Extensions.swift
//  user_list_view
//
//  Created by Eri on 11/6/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

extension UIColor {
    static let darkColor = UIColor(r: 0, g: 100, b: 100)
    static let lightColor = UIColor(r: 0, g: 120, b: 120)
    static let superLightColor = UIColor(r: 0, g: 250, b: 250)
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView
{
    func loadImageUsingCacheWithURLStr(urlStr: String)
    {
        self.image = nil
        
        // check for cached image first
        if let cachedImage = imageCache.object(forKey: urlStr as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlStr)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!) {
                    print(urlStr)
                    print(downloadedImage.size.width)
                    print(downloadedImage.size.height)
                    imageCache.setObject(downloadedImage, forKey: urlStr as AnyObject)
                    self.image = downloadedImage
                }
            })
            
        }
        
        task.resume()
    }
}
