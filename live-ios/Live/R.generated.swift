//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)
  
  static func validate() throws {
    try font.validate()
    try intern.validate()
  }
  
  /// This `R.color` struct is generated, and contains static references to 0 colors.
  struct color {
    fileprivate init() {}
  }
  
  /// This `R.file` struct is generated, and contains static references to 2 files.
  struct file {
    /// Resource file `Raleway-Regular.ttf`.
    static let ralewayRegularTtf = Rswift.FileResource(bundle: R.hostingBundle, name: "Raleway-Regular", pathExtension: "ttf")
    /// Resource file `person.pdf`.
    static let personPdf = Rswift.FileResource(bundle: R.hostingBundle, name: "person", pathExtension: "pdf")
    
    /// `bundle.url(forResource: "Raleway-Regular", withExtension: "ttf")`
    static func ralewayRegularTtf(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.ralewayRegularTtf
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "person", withExtension: "pdf")`
    static func personPdf(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.personPdf
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.font` struct is generated, and contains static references to 1 fonts.
  struct font: Rswift.Validatable {
    /// Font `Raleway-Regular`.
    static let ralewayRegular = Rswift.FontResource(fontName: "Raleway-Regular")
    
    /// `UIFont(name: "Raleway-Regular", size: ...)`
    static func ralewayRegular(size: CGFloat) -> UIKit.UIFont? {
      return UIKit.UIFont(resource: ralewayRegular, size: size)
    }
    
    static func validate() throws {
      if R.font.ralewayRegular(size: 42) == nil { throw Rswift.ValidationError(description:"[R.swift] Font 'Raleway-Regular' could not be loaded, is 'Raleway-Regular.ttf' added to the UIAppFonts array in this targets Info.plist?") }
    }
    
    fileprivate init() {}
  }
  
  /// This `R.image` struct is generated, and contains static references to 8 images.
  struct image {
    /// Image `gift-1`.
    static let gift1 = Rswift.ImageResource(bundle: R.hostingBundle, name: "gift-1")
    /// Image `gift-2`.
    static let gift2 = Rswift.ImageResource(bundle: R.hostingBundle, name: "gift-2")
    /// Image `gift-3`.
    static let gift3 = Rswift.ImageResource(bundle: R.hostingBundle, name: "gift-3")
    /// Image `heart`.
    static let heart = Rswift.ImageResource(bundle: R.hostingBundle, name: "heart")
    /// Image `icon-close`.
    static let iconClose = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon-close")
    /// Image `icon-gift`.
    static let iconGift = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon-gift")
    /// Image `icon-like`.
    static let iconLike = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon-like")
    /// Image `person`.
    static let person = Rswift.ImageResource(bundle: R.hostingBundle, name: "person")
    
    /// `UIImage(named: "gift-1", bundle: ..., traitCollection: ...)`
    static func gift1(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.gift1, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "gift-2", bundle: ..., traitCollection: ...)`
    static func gift2(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.gift2, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "gift-3", bundle: ..., traitCollection: ...)`
    static func gift3(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.gift3, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "heart", bundle: ..., traitCollection: ...)`
    static func heart(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.heart, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon-close", bundle: ..., traitCollection: ...)`
    static func iconClose(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.iconClose, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon-gift", bundle: ..., traitCollection: ...)`
    static func iconGift(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.iconGift, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon-like", bundle: ..., traitCollection: ...)`
    static func iconLike(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.iconLike, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "person", bundle: ..., traitCollection: ...)`
    static func person(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.person, compatibleWith: traitCollection)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.nib` struct is generated, and contains static references to 1 nibs.
  struct nib {
    /// Nib `GiftDisplayView`.
    static let giftDisplayView = _R.nib._GiftDisplayView()
    
    /// `UINib(name: "GiftDisplayView", in: bundle)`
    static func giftDisplayView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.giftDisplayView)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.reuseIdentifier` struct is generated, and contains static references to 1 reuse identifiers.
  struct reuseIdentifier {
    /// Reuse identifier `cell`.
    static let cell: Rswift.ReuseIdentifier<UIKit.UITableViewCell> = Rswift.ReuseIdentifier(identifier: "cell")
    
    fileprivate init() {}
  }
  
  /// This `R.segue` struct is generated, and contains static references to 2 view controllers.
  struct segue {
    /// This struct is generated for `AudienceViewController`, and contains static references to 1 segues.
    struct audienceViewController {
      /// Segue identifier `overlay`.
      static let overlay: Rswift.StoryboardSegueIdentifier<UIKit.UIStoryboardSegue, AudienceViewController, LiveOverlayViewController> = Rswift.StoryboardSegueIdentifier(identifier: "overlay")
      
      /// Optionally returns a typed version of segue `overlay`.
      /// Returns nil if either the segue identifier, the source, destination, or segue types don't match.
      /// For use inside `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)`.
      static func overlay(segue: UIKit.UIStoryboardSegue) -> Rswift.TypedStoryboardSegueInfo<UIKit.UIStoryboardSegue, AudienceViewController, LiveOverlayViewController>? {
        return Rswift.TypedStoryboardSegueInfo(segueIdentifier: R.segue.audienceViewController.overlay, segue: segue)
      }
      
      fileprivate init() {}
    }
    
    /// This struct is generated for `BroadcasterViewController`, and contains static references to 1 segues.
    struct broadcasterViewController {
      /// Segue identifier `overlay`.
      static let overlay: Rswift.StoryboardSegueIdentifier<UIKit.UIStoryboardSegue, BroadcasterViewController, LiveOverlayViewController> = Rswift.StoryboardSegueIdentifier(identifier: "overlay")
      
      /// Optionally returns a typed version of segue `overlay`.
      /// Returns nil if either the segue identifier, the source, destination, or segue types don't match.
      /// For use inside `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)`.
      static func overlay(segue: UIKit.UIStoryboardSegue) -> Rswift.TypedStoryboardSegueInfo<UIKit.UIStoryboardSegue, BroadcasterViewController, LiveOverlayViewController>? {
        return Rswift.TypedStoryboardSegueInfo(segueIdentifier: R.segue.broadcasterViewController.overlay, segue: segue)
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  /// This `R.storyboard` struct is generated, and contains static references to 2 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()
    /// Storyboard `Main`.
    static let main = _R.storyboard.main()
    
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    
    /// `UIStoryboard(name: "Main", bundle: ...)`
    static func main(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.main)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.string` struct is generated, and contains static references to 0 localization tables.
  struct string {
    fileprivate init() {}
  }
  
  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }
    
    fileprivate init() {}
  }
  
  fileprivate class Class {}
  
  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    try storyboard.validate()
    try nib.validate()
  }
  
  struct nib: Rswift.Validatable {
    static func validate() throws {
      try _GiftDisplayView.validate()
    }
    
    struct _GiftDisplayView: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "GiftDisplayView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      static func validate() throws {
        if UIKit.UIImage(named: "gift-1", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'gift-1' is used in nib 'GiftDisplayView', but couldn't be loaded.") }
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      try main.validate()
    }
    
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType {
      typealias InitialController = UIKit.UIViewController
      
      let bundle = R.hostingBundle
      let name = "LaunchScreen"
      
      fileprivate init() {}
    }
    
    struct main: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = NavigationController
      
      let audience = StoryboardViewControllerResource<AudienceViewController>(identifier: "audience")
      let broadcast = StoryboardViewControllerResource<BroadcasterViewController>(identifier: "broadcast")
      let bundle = R.hostingBundle
      let giftChooser = StoryboardViewControllerResource<GiftChooserViewController>(identifier: "giftChooser")
      let name = "Main"
      
      func audience(_: Void = ()) -> AudienceViewController? {
        return UIKit.UIStoryboard(resource: self).instantiateViewController(withResource: audience)
      }
      
      func broadcast(_: Void = ()) -> BroadcasterViewController? {
        return UIKit.UIStoryboard(resource: self).instantiateViewController(withResource: broadcast)
      }
      
      func giftChooser(_: Void = ()) -> GiftChooserViewController? {
        return UIKit.UIStoryboard(resource: self).instantiateViewController(withResource: giftChooser)
      }
      
      static func validate() throws {
        if UIKit.UIImage(named: "gift-3") == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'gift-3' is used in storyboard 'Main', but couldn't be loaded.") }
        if UIKit.UIImage(named: "person") == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'person' is used in storyboard 'Main', but couldn't be loaded.") }
        if UIKit.UIImage(named: "gift-1") == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'gift-1' is used in storyboard 'Main', but couldn't be loaded.") }
        if UIKit.UIImage(named: "gift-2") == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'gift-2' is used in storyboard 'Main', but couldn't be loaded.") }
        if UIKit.UIImage(named: "icon-like") == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'icon-like' is used in storyboard 'Main', but couldn't be loaded.") }
        if _R.storyboard.main().giftChooser() == nil { throw Rswift.ValidationError(description:"[R.swift] ViewController with identifier 'giftChooser' could not be loaded from storyboard 'Main' as 'GiftChooserViewController'.") }
        if _R.storyboard.main().audience() == nil { throw Rswift.ValidationError(description:"[R.swift] ViewController with identifier 'audience' could not be loaded from storyboard 'Main' as 'AudienceViewController'.") }
        if _R.storyboard.main().broadcast() == nil { throw Rswift.ValidationError(description:"[R.swift] ViewController with identifier 'broadcast' could not be loaded from storyboard 'Main' as 'BroadcasterViewController'.") }
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  fileprivate init() {}
}
