//
//  ContentView.swift
//  Context
//
//  Created by ihlas on 4.02.2022.
//
import CoreML
import SwiftUI

struct ContentView: View{
@State private var wakeUp = defaultWakeTime
@State private var sleepAmount = 8.0
@State private var coffeeAmount = 1 //eklenecek olan miktar
    
@State private var alertTitle = ""
@State private var alertMessage = ""
@State private var showinAlert = false
    

        
   static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
            
        }
  


    var body: some View{
        NavigationView{
        Form{
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desire amount of sleep")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .lineLimit(9)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 1...12, step: 0.25)
                
                
                Text("Daily coffee intake")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .lineLimit(9)
                Stepper(coffeeAmount == 1 ?  "1 cup": "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
            }
            .navigationTitle("Better Rest")
            .toolbar{
                Button("Calculate", action: calculateBedTime)
            }
            
            .alert(alertTitle, isPresented: $showinAlert){
                Button("OK"){}
            }message: {
            Text(alertMessage)
            }
}
}
    func calculateBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculate(configuration: config)
            //MORE COME TO COME HERE
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        }catch{
            //Sthing  went wrog
            alertTitle =  "Error"
            alertMessage = "Sorry, there was some problem"
        }
        showinAlert = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
