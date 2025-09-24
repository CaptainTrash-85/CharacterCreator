import SwiftUI
import AppKit // for Copy Prompt to Clipboard Button

enum Gender {
    case female
    case male
}

struct ContentView: View {
    // MARK: - Selection variables
    @State private var age: String = ""
    @State private var ethnicity: String = ""
    @State private var skinTone: String = ""
    @State private var bodyType: String = ""
    @State private var breastSize: String = ""
    @State private var faceShape: String = ""
    @State private var eyeColor: String = ""
    @State private var hairstyleCategory: String = ""
    @State private var hairstyleItem: String = ""
    @State private var hairColor: String = ""
    @State private var makeup: String = "" // used for Makeup female or FacialHair male
    @State private var expression: String = ""
    @State private var accessory: String = ""

    @State private var clothingCategory: String = ""
    @State private var clothingSelections: [String: String] = [:]

    @State private var poseCategory: String = ""
    @State private var poseItem: String = ""
    @State private var customPose: String = ""

    @State private var camera: String = ""
    @State private var environment: String = ""
    @State private var lighting: String = ""

    @State private var generatedPrompt: String = ""

    @State private var justCopied = false

    @State private var includeAge = true
    @State private var includeEthnicity = true
    @State private var includeSkinTone = true
    @State private var includeBodyType = true
    @State private var includeBreastSize = true
    @State private var includeFaceShape = true
    @State private var includeEyeColor = true
    @State private var includeHairstyle = true
    @State private var includeHairColor = true
    @State private var includeMakeup = true
    @State private var includeExpression = true
    @State private var includeClothing = true
    @State private var includeAccessories = true
    @State private var includePose = true
    @State private var includeCamera = true
    @State private var includeEnvironment = true
    @State private var includeLighting = true

    @State private var data: CharacterData?

    @State private var hairstyleCategories: [String] = []
    @State private var currentHairstyleItems: [String] = []

    @State private var clothingCategoryKeys: [String] = []
    @State private var clothingSubKeys: [String] = []
    @State private var clothingItemsForSub: [String: [String]] = [:]

    @State private var gender: Gender = .female

    // Cyberpunk-ish Colors
    private let neonCyan = Color(red: 0.0, green: 0.94, blue: 0.96)
    private let neonPink = Color(red: 1.0, green: 0.18, blue: 0.66)
    private let panelDark = Color(red: 0.05, green: 0.06, blue: 0.08)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(neonPink, neonCyan)
                            .font(.title2)
                        Text("Character Prompt Builder")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Spacer()

                        Picker("Gender", selection: $gender) {
                            Text("Female").tag(Gender.female)
                            Text("Male").tag(Gender.male)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 200)
                        .onChange(of: gender) { _, _ in
                            resetAll()
                            loadData()
                        }
                    }
                    .padding(.horizontal, 8)

                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 18) {
                            groupBox(title: "Basic Info", systemImage: "person") {
                                hstackTogglePicker(toggle: $includeAge, label: "Age", selection: $age, options: data?.ages ?? [])
                                hstackTogglePicker(toggle: $includeEthnicity, label: "Ethnicity", selection: $ethnicity, options: data?.ethnicities ?? [])
                            }

                            groupBox(title: "Appearance", systemImage: "face.smiling") {
                                hstackTogglePicker(toggle: $includeSkinTone, label: "Skin Tone", selection: $skinTone, options: data?.skinTones ?? [])
                                hstackTogglePicker(toggle: $includeBodyType, label: "Body Type", selection: $bodyType, options: data?.bodyTypes ?? [])

                                if gender == .female {
                                    hstackTogglePicker(toggle: $includeBreastSize, label: "Breast Size", selection: $breastSize, options: data?.breastSizes ?? [])
                                }

                                hstackTogglePicker(toggle: $includeFaceShape, label: "Face Shape", selection: $faceShape, options: data?.faceShapes ?? [])
                                hstackTogglePicker(toggle: $includeEyeColor, label: "Eye Color", selection: $eyeColor, options: data?.eyeColors ?? [])

                                Group {
                                    HStack {
                                        Toggle("Hairstyle", isOn: $includeHairstyle)
                                            .toggleStyle(SwitchToggleStyle(tint: neonCyan))
                                        if includeHairstyle {
                                            Picker("Category", selection: $hairstyleCategory) {
                                                ForEach(hairstyleCategories, id: \.self) { Text($0) }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .accentColor(neonCyan)

                                            Picker("Style", selection: $hairstyleItem) {
                                                ForEach(currentHairstyleItems, id: \.self) { Text($0) }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .accentColor(neonPink)
                                        }
                                    }
                                }
                                .id("hair-\(hairstyleCategory)")
                                .animation(nil, value: hairstyleCategory)

                                hstackTogglePicker(toggle: $includeHairColor, label: "Hair Color", selection: $hairColor, options: data?.hairColors ?? [])

                                if gender == .female {
                                    hstackTogglePicker(toggle: $includeMakeup, label: "Makeup", selection: $makeup, options: data?.makeups ?? [])
                                } else {
                                    hstackTogglePicker(toggle: $includeMakeup, label: "Facial Hair", selection: $makeup, options: data?.facialHair ?? [])
                                }

                                hstackTogglePicker(toggle: $includeExpression, label: "Expression", selection: $expression, options: data?.expressions ?? [])
                            }
                        }
                        .frame(minWidth: 300, maxWidth: 450)

                        VStack(alignment: .leading, spacing: 18) {
                            groupBox(title: "Clothing", systemImage: "tshirt") {
                                Toggle("Include Clothing", isOn: $includeClothing)
                                    .toggleStyle(SwitchToggleStyle(tint: neonCyan))
                                if includeClothing {
                                    Picker("Category", selection: $clothingCategory) {
                                        ForEach(clothingCategoryKeys, id: \.self) { Text($0) }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(neonCyan)

                                    Group {
                                        if let cat = data?.clothingCategories[clothingCategory] {
                                            switch cat {
                                            case .items(let arr):
                                                Picker("Item", selection: selectionBinding(for: "Item")) {
                                                    ForEach(arr, id: \.self) { Text($0) }
                                                }
                                                .pickerStyle(MenuPickerStyle())
                                                .accentColor(neonPink)

                                            case .subcategories:
                                                ForEach(clothingSubKeys, id: \.self) { sub in
                                                    Picker(sub, selection: selectionBinding(for: sub)) {
                                                        ForEach(clothingItemsForSub[sub] ?? [], id: \.self) { Text($0) }
                                                    }
                                                    .pickerStyle(MenuPickerStyle())
                                                    .accentColor(neonPink)
                                                }
                                            }
                                        }
                                    }
                                    .id("clothing-\(clothingCategory)")
                                    .animation(nil, value: clothingCategory)
                                }
                            }

                            groupBox(title: "Accessories", systemImage: "eyeglasses") {
                                hstackTogglePicker(
                                    toggle: $includeAccessories,
                                    label: "Accessories",
                                    selection: $accessory,
                                    options: data?.accessories ?? []
                                )
                            }

                            groupBox(title: "Pose & Camera", systemImage: "figure.stand") {
                                Toggle("Include Pose", isOn: $includePose)
                                    .toggleStyle(SwitchToggleStyle(tint: neonCyan))

                                if includePose {
                                    Picker("Category", selection: $poseCategory) {
                                        ForEach(data?.poseCategories.keys.sorted() ?? [], id: \.self) { Text($0) }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(neonCyan)

                                    Picker("Pose", selection: $poseItem) {
                                        ForEach(data?.poseCategories[poseCategory] ?? [], id: \.self) { Text($0) }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(neonPink)
                                } else {
                                    TextField("Custom Pose (optional)", text: $customPose)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .padding(8)
                                        .background(panelDark)
                                        .cornerRadius(6)
                                        .foregroundColor(.white)
                                }

                                Toggle("Include Camera", isOn: $includeCamera)
                                    .toggleStyle(SwitchToggleStyle(tint: neonCyan))
                                if includeCamera {
                                    Picker("Camera", selection: $camera) {
                                        ForEach(data?.cameras ?? [], id: \.self) { Text($0) }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(neonPink)
                                }
                            }

                            groupBox(title: "Environment & Lighting", systemImage: "map") {
                                hstackTogglePicker(toggle: $includeEnvironment, label: "Environment", selection: $environment, options: data?.environments ?? [])
                                hstackTogglePicker(toggle: $includeLighting, label: "Lighting", selection: $lighting, options: data?.lightings ?? [])
                            }

                            HStack(spacing: 12) {
                                Button(action: randomizeVisible) {
                                    HStack {
                                        Image(systemName: "dice")
                                        Text("Randomize").fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.06))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(neonCyan.opacity(0.08)))
                                }

                                Button(action: generatePrompt) {
                                    HStack {
                                        Image(systemName: "wand.and.stars")
                                        Text("Generate").fontWeight(.semibold)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(gradient: Gradient(colors: [neonPink, neonCyan]), startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                    .shadow(color: neonCyan.opacity(0.25), radius: 10, x: 0, y: 4)
                                }

                                Button(action: copyPrompt) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "doc.on.doc")
                                        Text(justCopied ? "Copied!" : "Copy")
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(generatedPrompt.isEmpty ? 0.03 : 0.08))
                                    .foregroundColor(generatedPrompt.isEmpty ? .gray : .white)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(neonCyan.opacity(generatedPrompt.isEmpty ? 0.04 : 0.12)))
                                }
                                .disabled(generatedPrompt.isEmpty)
                                .help("Copy the generated prompt to the clipboard")
                            }
                        }
                        .frame(minWidth: 400, maxWidth: 600)

                        Spacer()
                    }

                    if !generatedPrompt.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Generated Prompt")
                                .foregroundColor(.white)
                                .font(.headline)
                            TextEditor(text: $generatedPrompt)
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .frame(minHeight: 220)
                                .padding(8)
                                .background(panelDark)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(neonCyan.opacity(0.6), lineWidth: 1))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear { loadData() }
        .onChange(of: hairstyleCategory) { _, newCat in
            currentHairstyleItems = data?.hairstyles[newCat] ?? []
            if !currentHairstyleItems.contains(hairstyleItem) {
                hairstyleItem = ""
            }
        }
        .onChange(of: clothingCategory) { _, newCat in
            if let cat = data?.clothingCategories[newCat] {
                switch cat {
                case .items(let items):
                    clothingSubKeys = ["Item"]
                    clothingItemsForSub = ["Item": items]
                case .subcategories(let dict):
                    clothingSubKeys = Array(dict.keys).sorted()
                    clothingItemsForSub = dict
                }
            } else {
                clothingSubKeys = []
                clothingItemsForSub = [:]
            }
            updateClothingSelectionsForCategory(newCat)
        }
        .frame(minWidth: 1000, minHeight: 700)
    }

    // MARK: - Prompt Generator
    func generatePrompt() {
        func clean(_ s: String) -> String { s.trimmingCharacters(in: .whitespacesAndNewlines) }
        var sentences: [String] = []

        let ethnicityText = (includeEthnicity && !ethnicity.isEmpty) ? "\(ethnicity) " : ""
        let genderNoun = (gender == .female) ? "woman" : "man"

        if includeCamera && !camera.isEmpty {
            sentences.append("A \(camera) of an \(ethnicityText)\(genderNoun).")
        } else {
            sentences.append("A full-body portrait of an \(ethnicityText)\(genderNoun).")
        }

        if includeAge && !age.isEmpty { sentences.append("Age: \(age).") }
        if includeSkinTone && !skinTone.isEmpty { sentences.append("Skin Tone: \(skinTone).") }
        if includeBodyType && !bodyType.isEmpty { sentences.append("Body Type: \(bodyType).") }
        if gender == .female {
            if includeBreastSize && !breastSize.isEmpty { sentences.append("Breast Size: \(breastSize).") }
        }
        if includeFaceShape && !faceShape.isEmpty { sentences.append("Face Shape: \(faceShape).") }
        if includeEyeColor && !eyeColor.isEmpty { sentences.append("Eye Color: \(eyeColor).") }
        if includeHairstyle && !hairstyleItem.isEmpty { sentences.append("Hairstyle: \(hairstyleItem).") }
        if includeHairColor && !hairColor.isEmpty { sentences.append("Hair Color: \(hairColor).") }

        if gender == .female {
            if includeMakeup && !makeup.isEmpty { sentences.append("Makeup: \(makeup).") }
        } else {
            if includeMakeup && !makeup.isEmpty { sentences.append("Facial Hair: \(makeup).") }
        }

        if includeExpression && !expression.isEmpty { sentences.append("Facial Expression: \(expression).") }

        if includeClothing {
            var clothingParts: [String] = []
            for (_, sel) in clothingSelections {
                if !sel.isEmpty { clothingParts.append(sel) }
            }
            if !clothingParts.isEmpty {
                sentences.append("Wearing: \(clothingParts.joined(separator: ", ")).")
            }
        }

        if includeAccessories && !accessory.isEmpty { sentences.append("Accessories: \(accessory).") }

        if includePose {
            if !poseItem.isEmpty { sentences.append("Pose: \(poseItem).") }
        } else if !customPose.isEmpty {
            sentences.append("Pose: \(customPose).")
        }

        if includeEnvironment && !environment.isEmpty { sentences.append("Environment: \(environment).") }
        if includeLighting && !lighting.isEmpty { sentences.append("Lighting: \(lighting).") }

        generatedPrompt = sentences.joined(separator: " ")
    }

    // MARK: - Randomizer
    func randomizeVisible() {
        guard let d = data else { return }

        func pick(_ arr: [String]) -> String {
            let filtered = arr.filter { !$0.hasPrefix("+") && !$0.hasSuffix("+") }
            return filtered.randomElement() ?? ""
        }

        if includeAge { age = pick(d.ages) }
        if includeEthnicity { ethnicity = pick(d.ethnicities) }
        if includeSkinTone { skinTone = pick(d.skinTones) }
        if includeBodyType { bodyType = pick(d.bodyTypes) }

        if gender == .female {
            if includeBreastSize { breastSize = pick(d.breastSizes ?? []) }
            if includeMakeup { makeup = pick(d.makeups ?? []) }
        } else {
            if includeMakeup { makeup = pick(d.facialHair ?? []) }
        }

        if includeFaceShape { faceShape = pick(d.faceShapes) }
        if includeEyeColor { eyeColor = pick(d.eyeColors) }

        if includeHairstyle {
            hairstyleCategory = d.hairstyles.keys.sorted().randomElement() ?? ""
            hairstyleItem = pick(d.hairstyles[hairstyleCategory] ?? [])
        }
        if includeHairColor { hairColor = pick(d.hairColors) }

        if includeClothing {
            clothingCategory = d.clothingCategories.keys.sorted().randomElement() ?? ""
            if let cat = d.clothingCategories[clothingCategory] {
                switch cat {
                case .items(let items):
                    clothingSelections = ["Item": pick(items)]
                case .subcategories(let dict):
                    var newSelections: [String: String] = [:]
                    for (sub, items) in dict {
                        newSelections[sub] = pick(items)
                    }
                    clothingSelections = newSelections
                }
            }
        }
    }

    // MARK: - Helpers
    private func hstackTogglePicker(toggle: Binding<Bool>, label: String, selection: Binding<String>, options: [String]) -> some View {
        HStack {
            Toggle(label, isOn: toggle)
                .toggleStyle(SwitchToggleStyle(tint: neonCyan))
            if toggle.wrappedValue {
                Picker(label, selection: selection) {
                    ForEach(options, id: \.self) { Text($0) }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(neonPink)
            }
        }
    }

    private func groupBox<Content: View>(title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundColor(neonCyan)
            content()
        }
        .padding()
        .background(panelDark)
        .cornerRadius(12)
    }

    private func selectionBinding(for subcategory: String) -> Binding<String> {
        Binding<String>(
            get: { clothingSelections[subcategory] ?? "" },
            set: { clothingSelections[subcategory] = $0 }
        )
    }

    private func copyPrompt() {
        guard !generatedPrompt.isEmpty else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(generatedPrompt, forType: .string)

        justCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { justCopied = false }
    }

    private func updateClothingSelectionsForCategory(_ category: String) {
        if let cat = data?.clothingCategories[category] {
            switch cat {
            case .items:
                clothingSelections = ["Item": ""]
            case .subcategories(let dict):
                var newSelections: [String: String] = [:]
                for sub in dict.keys {
                    newSelections[sub] = ""
                }
                clothingSelections = newSelections
            }
        } else {
            clothingSelections = [:]
        }
    }

    private func resetAll() {
        age = ""; ethnicity = ""; skinTone = ""; bodyType = ""; breastSize = ""
        faceShape = ""; eyeColor = ""; hairstyleCategory = ""; hairstyleItem = ""
        hairColor = ""; makeup = ""; expression = ""; accessory = ""
        clothingCategory = ""; clothingSelections = [:]
        poseCategory = ""; poseItem = ""; customPose = ""
        camera = ""; environment = ""; lighting = ""
        generatedPrompt = ""
    }

    private func loadData() {
        let jsonString: String
        switch gender {
        case .female:
            jsonString = embeddedCharacterDataJSON
        case .male:
            jsonString = embeddedCharacterDataJSONMale
        }

        if let jsonData = jsonString.data(using: .utf8),
           let decodedData = try? JSONDecoder().decode(CharacterData.self, from: jsonData) {
            self.data = decodedData

            hairstyleCategories = Array(decodedData.hairstyles.keys).sorted()
            clothingCategoryKeys = Array(decodedData.clothingCategories.keys).sorted()

            currentHairstyleItems = []
            clothingSubKeys = []
            clothingItemsForSub = [:]
        } else {
            print("❌ Error loading embedded JSON")
        }
    }
}

