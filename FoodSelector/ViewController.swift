//
//  ViewController.swift
//  FoodSelector
//
//  Created by there#2 on 11/28/23.
//

import UIKit
import SystemConfiguration

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    @IBOutlet weak var burgerImageView: UIImageView!
    @IBOutlet weak var cakeImageView: UIImageView!
    @IBOutlet weak var hotdogImageView: UIImageView!
    @IBOutlet weak var pizzaImageView: UIImageView!
    @IBOutlet weak var cookieImageView: UIImageView!
    
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
      // Check for internet connectivity
      if !isConnectedToNetwork() {
          // If not connected, show alert
          showAlert(message: "No internet connection.")
      }
      
      animateFloating(floatingImageView: burgerImageView)
      animateFloating(floatingImageView: cakeImageView)
      animateFloating(floatingImageView: hotdogImageView)
      animateFloating(floatingImageView: pizzaImageView)
      animateFloating(floatingImageView: cookieImageView)
   }
   
   func animateFloating(floatingImageView: UIImageView) {
      // Generate random target position within the screen bounds
      let targetX = CGFloat.random(in: 10...(view.bounds.width - floatingImageView.bounds.width-10))
      let targetY = CGFloat.random(in: 50...(view.bounds.height/2 - floatingImageView.bounds.height))
      
      // Calculate a random duration (in secends)
      let duration = CGFloat.random(in: 3...7)
      
      // Calculate a random angle for rotation (in radians)
      let randomAngle = CGFloat.random(in: 0...(.pi * 2))
      
      // Animate the image view to move to the target position
      UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
         floatingImageView.center = CGPoint(x: targetX, y: targetY)
         floatingImageView.transform = CGAffineTransform(rotationAngle: randomAngle)
      }) { _ in
         // Animation complete, recursively call animateFloating to continue floating
         self.animateFloating(floatingImageView: floatingImageView)
      }
   }

   func isConnectedToNetwork() -> Bool {
           var zeroAddress = sockaddr_in()
           zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
           zeroAddress.sin_family = sa_family_t(AF_INET)
           
           guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
               $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                   SCNetworkReachabilityCreateWithAddress(nil, $0)
               }
           }) else {
               return false
           }
           
           var flags: SCNetworkReachabilityFlags = []
           if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
               return false
           }
           
           let isReachable = flags.contains(.reachable)
           let needsConnection = flags.contains(.connectionRequired)
           
           return (isReachable && !needsConnection)
       }
   
   func showAlert(message: String) {
       let alertController = UIAlertController(title: "No Internet Connection", message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
       alertController.addAction(okAction)
       self.present(alertController, animated: true, completion: nil)
   }
   
}
