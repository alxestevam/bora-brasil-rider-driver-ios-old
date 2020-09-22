//
//  ReviewTravelViewController.swift
//  rider
//
//  Created by Victor Baleeiro on 19/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

//MARK: - Imports
import Kingfisher


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
    var travel: Request = Request.shared
    var onChangeBlock: ((_ object: Any?, _ isChange: Bool) -> Void)? = nil
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
        self.tbvCard.backgroundColor = .white
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
    
    //MARK: - Request
    private func sendReview() {
        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        ReviewDriver(review: Review(score: self.starsInt, review: self.textComment)).execute() { result in
            switch result {
            case .success(_):
                LoadingOverlay.shared.hideOverlayView()
                DialogBuilder.alertOnSuccess(message: "Avaliação enviada")
                Request.shared.status = .Finished
                if let compl = self.onChangeBlock { compl(nil, true) }
                self.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                error.showAlert()
            }
        }
    }
    
    
    //MARK: - Action
    @IBAction func sendReview(_ sender: GradientButton) {
        self.sendReview()
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
        view.imageView.layer.borderColor = UIColor.white.cgColor
        view.imageView.layer.borderWidth = 2.0
        
        // Data
        if let driverImage = travel.driver?.media?.address {
            let processor = DownsamplingImageProcessor(size: view.imageView.intrinsicContentSize) |> RoundCornerImageProcessor(cornerRadius: view.imageView.intrinsicContentSize.width / 2)
            let url = URL(string: Config.Backend + driverImage.replacingOccurrences(of: " ", with: "%20"))
            view.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Nobody"), options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ], completionHandler:  { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            })
        }
        view.textLabel?.text = travel.driver?.displayName
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
            cell.setupData(travel)
            return cell
            
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewInfoCell", for: indexPath) as! ReviewInfoCell
            cell.setupData(travel)
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

