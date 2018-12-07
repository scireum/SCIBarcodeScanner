extension UIView {
    /**
     Variable for current top view controller.
     */
    var currentTopViewController: UIViewController? {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController  else {
            print("Could not load RootViewController")
            return self.currentTopViewController
        }

        guard let topVC = rootVC.presentedViewController else {
            print("Could not load TopViewController")
            return rootVC
        }

        return topVC
    }

}
