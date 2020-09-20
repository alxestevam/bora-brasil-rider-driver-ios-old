//
//  ReviewTravelViewController.swift
//  rider
//
//  Created by Victor Baleeiro on 19/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

//MARK: - Dimensions
private enum Dimensions {
    static let headerHeight: CGFloat = 190.0
    static let totalItens: Int = 4
}


class ReviewTravelViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet fileprivate weak var viewContent: UIView!
    @IBOutlet fileprivate weak var tbvCard: UITableView!
    @IBOutlet var footerbtnSendReview: GradientButton!
    @IBOutlet var footerViewContent: UIView!
    private var rider = try! Rider(from: UserDefaultsConfig.user!)
    private var request: Request = Request()
    private var textComment: String = "" {
        didSet {
            self.validateData()
        }
    }
    private var starsInt = 0 {
        didSet {
            self.validateData()
        }
    }
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupData()
        setupText()
    }
    
    
    //MARK: - Setup
    private func setupLayout() {
        self.view.backgroundColor = .clear
        self.viewContent.backgroundColor = .black
        self.viewContent.alpha = 0.3
        self.tbvCard.backgroundColor = Color.orange.rgb_236_106_53
        self.tbvCard.clipsToBounds = true
        self.tbvCard.layer.cornerRadius = 20.0
        self.tbvCard.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.tbvCard.layer.shadowColor = UIColor.gray.cgColor
        self.tbvCard.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.tbvCard.layer.shadowRadius = 12.0
        self.tbvCard.layer.shadowOpacity = 0.7
        self.tbvCard.separatorStyle = .none
        self.footerViewContent.backgroundColor = .white
        self.footerViewContent.clipsToBounds = true
        self.footerViewContent.layer.cornerRadius = 20.0
        self.footerViewContent.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        self.setupButton(button: self.footerbtnSendReview, isEnable: false)
        self.tbvCard.register(ReviewHeaderView.nib, forHeaderFooterViewReuseIdentifier: ReviewHeaderView.reuseIdentifier)
    }
    
    private func setupData() {
        self.tbvCard.delegate = self
        self.tbvCard.dataSource = self
    }
    
    private func setupText() {
        
    }
    
    //MARK: - RequestHttp
    private func fetchCards() {
        
    }
    
    
    //MARK: - Action
    @IBAction func presentAddCard(_ sender: UIButton) {
        
    }
    
    
    //MARK: - Aux
    private func setupButton(button: GradientButton, isEnable: Bool) {
        button.firstColor = (isEnable) ? Color.orange.rgb_255_152_0 : Color.gray.rgb_240_240_240
        button.secondColor = (isEnable) ? Color.orange.rgb_236_106_53 : Color.gray.rgb_240_240_240
        button.setTitle("ENVIAR AVALIAÇÃO", for: .normal)
        button.setTitle("ENVIAR AVALIAÇÃO", for: .selected)
        button.setTitleColor((isEnable) ? .white : .gray, for: .normal)
        button.setTitleColor((isEnable) ? .white : .gray, for: .selected)
        button.isEnabled = isEnable
    }
    
    private func validateData() {
        setupButton(button: self.footerbtnSendReview, isEnable: self.starsInt > 0 && !self.textComment.isEmpty)
    }
}


//MARK: - UITableViewDelegate && UITableViewDataSource
extension ReviewTravelViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Dimensions.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: ReviewHeaderView.reuseIdentifier)
                as? ReviewHeaderView
        else {
            return nil
        }
        
        // Layout
        let gradientImage = CAGradientLayer.viewToImageGradient(on: view.viewContent)
        view.viewContent.backgroundColor = UIColor(patternImage: gradientImage!)
        view.textLabel?.textColor = .white
        view.imageView.layer.masksToBounds = true
        view.imageView.layer.cornerRadius = view.imageView.bounds.width / 2
        // Data
        view.textLabel?.text = "Bora Brasil Motorista"
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Dimensions.totalItens
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTextFieldCell", for: indexPath) as! ReviewTextFieldCell
            cell.textDelegate = self
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewStarCell", for: indexPath) as! ReviewStarCell
            cell.starDelegate = self
            return cell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewValuesCell", for: indexPath) as! ReviewValuesCell
            return cell
            
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewInfoCell", for: indexPath) as! ReviewInfoCell
            return cell
            
        } else {
            return UITableViewCell()
        }
        
    }
}


//MARK: - ReviewTextFieldCellDelegate
extension ReviewTravelViewController: ReviewTextFieldCellDelegate {
    func textInput(_ text: String) {
        print("COMENT: \(text)")
        self.textComment = text
    }
}


//MARK: - ReviewTextFieldCellDelegate
extension ReviewTravelViewController: ReviewStarCellDelegate {
    func selectedStar(_ value: Int) {
        print("RATING: \(value)")
        self.starsInt = value*20
    }
}

