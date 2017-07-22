//
//  ImageUtilities.swift
//  sangyxcdoe9
//
//  Created by Sangeeth K Sivakumar on 6/13/17.
/*
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import Vision
import CoreML

class ImageUtilities: NSObject {
  
 class func processImage(_ image: CGImage, completion: @escaping (Dictionary<String,Any>)->Void ){
    DispatchQueue.global(qos: .background).async {
      
      //Init Core Vision Model
      guard let vnCoreModel = try? VNCoreMLModel(for: VGG16().model) else { return }
      
      //Init Core Vision Request
      let request = VNCoreMLRequest(model: vnCoreModel) { (request, error) in
        guard let results = request.results as? [VNClassificationObservation] else { fatalError("Failure") }
        
        var finalDict = [String:Array<Any>]()
        var dataArray = Array<[String:String]>()
        
        for classification in results {
          if !classification.confidence.description.contains("-") {
            var dict = [String:String]()
            print(classification.confidence)
            dict["value"] = classification.confidence.description
            dict["identifier"] = classification.identifier
            dataArray.append(dict)
          }
        }
        finalDict["data"] = dataArray
        DispatchQueue.main.async {
          completion(finalDict)
        }
      }
      //Init Core Vision Request Handler
      let handler = VNImageRequestHandler(cgImage: image)
      
      //Perform Core Vision Request
      do {
        try handler.perform([request])
      } catch {
        print("did throw on performing a VNCoreRequest")
      }
    }
  }
  
  
}
