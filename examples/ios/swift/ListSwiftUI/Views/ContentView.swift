////////////////////////////////////////////////////////////////////////////
 //
 // Copyright 2020 Realm Inc.
 //
 // Licensed under the Apache License, Version 2.0 (the "License");
 // you may not use this file except in compliance with the License.
 // You may obtain a copy of the License at
 //
 // http://www.apache.org/licenses/LICENSE-2.0
 //
 // Unless required by applicable law or agreed to in writing, software
 // distributed under the License is distributed on an "AS IS" BASIS,
 // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 // See the License for the specific language governing permissions and
 // limitations under the License.
 //
 ////////////////////////////////////////////////////////////////////////////

import RealmSwift
import SwiftUI

// MARK: Dog Model
class Dog: Object, Identifiable {
    private static let dogNames = [
        "Bella", "Charlie", "Luna", "Lucy", "Max",
        "Bailey", "Cooper", "Daisy", "Sadie", "Molly"
    ]

    /// The unique id of this dog
    @objc dynamic var id = ObjectId.generate()
    /// The name of this dog
    @objc dynamic var name = dogNames.randomElement()!

    public static func ==(lhs: Dog, rhs: Dog) -> Bool {
        return lhs.isSameObject(as: rhs)
    }
}

// MARK: Person Model
class Person: Object, Identifiable {
    private static let peopleNames = [
        "Aoife", "Caoimhe", "Saoirse", "Ciara", "Niamh",
        "Conor", "Seán", "Oisín", "Patrick", "Cian"
    ]

    /// The name of the person
    @objc dynamic var name = peopleNames.randomElement()!
    /// The dogs this person has
    var dogs = RealmSwift.List<Dog>()
}

// MARK: Person View
struct PersonView: View {
    // bind a Person to the View
    @RealmState var person: Person

    var body: some View {
        VStack {
            // The write transaction for the name property of `Person`
            // is implicit here, and will occur on every edit
            TextField("name", text: $person.name)
                .font(Font.largeTitle.bold()).padding()
            List {
                // Using the `$` will bind the Dog List to the view.
                // Each Dog will be be bound as well, and will be
                // of type `Binding<Dog>`
                ForEach($person.dogs, id: \.id.wrappedValue) { dog in
                    // The write transaction for the name property of `Dog`
                    // is implicit here, and will occur on every edit.
                    TextField("dog name", text: dog.name)
                }
                // the remove method on the dogs list
                // will implicitly write and remove the dogs
                // at the offsets from the `onDelete(perform:)` method
                .onDelete(perform: $person.dogs.remove)
                // the move method on the dogs list
                // will implicitly write and move the dogs
                // to and from the offsets from the `onMove(perform:)` method
                .onMove(perform: $person.dogs.move)
            }
        }
        .navigationBarItems(trailing: Button("Add Dog") {
            // appending a dog to the dogs List implicitly
            // writes to the Realm, since it has been bound
            // to the view
            $person.dogs.append(Dog())
        })
    }
}

// MARK: Results View
struct ResultsView: View {
    @Environment(\.realm) var realm: Realm
    @RealmState(Person.self) var results

    var body: some View {
        return NavigationView {
            List {
                ForEach(results) { person in
                    NavigationLink(destination: PersonView(person: person)) {
                        Text(person.name)
                    }
                }
            }
            .navigationBarTitle("People", displayMode: .large)
            .navigationBarItems(trailing: Button("Add") {
                try! realm.write { realm.add(Person()) }
            })
        }
    }
}

@main
struct ContentView: SwiftUI.App {
    var realm = try! Realm()

    var view: some View {
        ResultsView().environment(\.realm, realm)
    }

    var body: some Scene {
        WindowGroup {
            view
        }
    }
}
