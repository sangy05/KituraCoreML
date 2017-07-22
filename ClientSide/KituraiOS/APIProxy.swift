import Kitura
import HeliumLogger
import LoggerAPI
import Foundation
import UIKit

class APIManager{
  var delegate:MainControllerDelegate?
  var mainRouter:Router?
  init(with mainRouter:Router?) {
    guard let router = mainRouter else{
      return
    }
    self.mainRouter = router
  }
  
  //Add DB CRUD Services
  func addServices(){
    
    //get
    mainRouter!.get("/test", handler: self.getTest)

    //POST
    mainRouter!.post("/data/analyzeImage",handler:self.notifyRequest,self.processRequest,self.responseProcessed)
  }
  
 func responseProcessed(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
     DispatchQueue.main.async {
      self.delegate!.didHitApi()
     }
     next()
  }
  
  func notifyRequest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    DispatchQueue.main.async {
      self.delegate!.didReceiveRequest(info: request.originalURL)
    }
    next()
  }
  
  func processRequest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    var dataa = Data()
    do {
      let data = try request.read(into: &dataa);
      print("success" + data.description);
      let image = UIImage(data: dataa);
      
      ImageUtilities.processImage(image!.cgImage!) { (result) in
        //print(result.description);
        let jsonResult = try! JSONSerialization.data(withJSONObject: result, options: JSONSerialization.WritingOptions.prettyPrinted)
        let finalData = NSString(data: jsonResult, encoding: String.Encoding.utf8.rawValue)
        response.send(finalData! as String)
        next()
      }
    }
    catch{
      print("error")
      next()
    }
  }
  
  public func getTest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    try response.status(.OK).send("Hello from Kitura-Starter!").end()
  }
  
}
