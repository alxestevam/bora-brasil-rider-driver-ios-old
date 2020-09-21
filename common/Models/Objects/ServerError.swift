//
//  ServerError.swift
//  Shared
//
//  Created by Manly Man on 11/22/19.
//  Copyright © 2019 Innomalist. All rights reserved.
//

import Foundation
import StatusAlert

public struct ServerError: Error, Codable {
    public var status: ErrorStatus
    public var message: String?
    
    func getMessage() -> String {
        if self.status != .Unknown {
            return self.status.localizedDescription
        } else if let _message = message {
            return _message
        } else {
            return NSLocalizedString("An unknown error happend", comment: "Error Status")
        }
    }
    
    public func showAlert() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
        let statusAlert = StatusAlert()
        statusAlert.title = NSLocalizedString("Error_Happened", comment: "Default title for any error occured")
        statusAlert.message = getMessage()
        statusAlert.canBePickedOrDismissed = true
        if #available(iOS 13.0, *) {
            statusAlert.appearance.tintColor = UIColor.label
        }
        statusAlert.image = UIImage(named: "alert_error")
        statusAlert.showInKeyWindow()
    }
}

public enum ErrorStatus: String, Codable {
    case DistanceCalculationFailed = "DistanceCalculationFailed"
    case DriversUnavailable = "DriversUnavailable"
    case ConfirmationCodeRequired = "ConfirmationCodeRequired"
    case ConfirmationCodeInvalid = "ConfirmationCodeInvalid"
    case OrderAlreadyTaken = "OrderAlreadyTaken"
    case CreditInsufficient = "CreditInsufficient"
    case CouponUsed = "CouponUsed"
    case CouponExpired = "CouponExpired"
    case CouponInvalid = "CouponInvalid"
    case Unknown = "Unknown"
    case Networking = "Networking"
    case FailedEncoding = "FailedEncoding"
    case FailedToVerify = "FailedToVerify"
    case RegionUnsupported = "RegionUnsupported"
    case NoServiceInRegion = "NoServiceInRegion"
    case PINCodeRequired = "PINCodeRequired"
    case OTPCodeRequired = "OTPCodeRequired"
    case RejectedByAntiFraud = "RejectedByAntiFraud"
    case PaymentError = "PaymentError"

    var localizedDescription: String {
        switch self {
        case .DistanceCalculationFailed:
            return NSLocalizedString("Falha no cálculo da distância entre pontos.", comment: "Error Status")
        case .DriversUnavailable:
            return NSLocalizedString("Nenhum motorista próximo encontrado", comment: "Error Status")
        case .ConfirmationCodeRequired:
            return NSLocalizedString("Código de confirmação é obrigatório", comment: "Error Status")
        case .ConfirmationCodeInvalid:
            return NSLocalizedString("Código de confirmação inválido", comment: "Error Status")
        case .OrderAlreadyTaken:
            return NSLocalizedString("Pedido já realizado", comment: "Error Status")
        case .Unknown:
            return NSLocalizedString("Ocorreu um erro ao tentar realizar a operação. Por favor, tente novamente", comment: "Error Status")
        case .Networking:
            return NSLocalizedString("Erro de rede", comment: "Error Status")
        case .FailedEncoding:
            return NSLocalizedString("Ocorreu um erro ao tentar realizar a operação. Por favor, tente novamente", comment: "Error Status")
        case .FailedToVerify:
            return NSLocalizedString("Falha na verificação", comment: "Error Status")
        case .RegionUnsupported:
            return NSLocalizedString("A região do local de recebimento não é suportada", comment: "Error Status")
        case .NoServiceInRegion:
            return NSLocalizedString("Nenhum serviço disponível atualmente em sua região.", comment: "Error Status")
        case .CreditInsufficient:
            return NSLocalizedString("Crédito insuficiente para esta ação.", comment: "Error Status")
        case .CouponUsed:
            return NSLocalizedString("O cupom já está sendo usado.", comment: "Error Status")
        case .CouponExpired:
            return NSLocalizedString("Cupom expirado.", comment: "Error Status")
        case .CouponInvalid:
            return NSLocalizedString("Cupom inválido.", comment: "Error Status")
        case .PINCodeRequired:
            return NSLocalizedString("Código PIN necessário", comment: "Error Status")
        case .OTPCodeRequired:
            return NSLocalizedString("OTP necessário", comment: "Error Status")
        case .RejectedByAntiFraud:
            return NSLocalizedString("A forma de pagamento do passageiro foi recusada.", comment: "Error Status")
        case .PaymentError:
            return NSLocalizedString("O seu pagamento foi rejeitado e a corrida cancelada.", comment: "Error Status")
        }
    }
}
