//
//  StringIdentifier.swift
//
//  Created by Victor Baleeiro on 24/10/19.
//  Copyright © 2019 Victor Baleeiro. All rights reserved.
//

import Foundation


enum StringIdentifier: String, CustomIdentifier {
    
    // Geral
    case gCarregandoDados
    case gSemInformacao
    case gAdicionar
    
    // Boas Vindas
    case bvTitulo1
    case bvDescricao1
    case bvTitulo2
    case bvDescricao2
    case bvTitulo3
    case bvDescricao3
    case bvTitulo4
    case bvDescricao4
    case bvBotaoPular
    
    // Login
    case lgTituloLogin
    case lgSubtituloLogin
    case lgTituloValidacao
    case lgSubtituloValidacao
    case lgCampoEmail
    case lgBotaoEnviar
    case lgBotaoEnviarInativo
    case lgBotaoNaoRecebiCodigo
    case lgBotaoEntrar
    case lgBotaoLoginFacebook
    case lgBotaoLoginGoogle
    case lgBotaoLoginEmail
    
    // Principal
    case pLabelNomeOla
    case pLabelNomeOlaComplemento
    case pLabelConsultar
    case pLabelConsultarDescricao
    case pLabelMeusPedidos
    case pLabelMeusPedidosDescricao
    case pLabelMeusVeiculos
    case pLabelMeusVeiculosDescricao
    case pLabelMinhaCNH
    case pLabelMinhaCNHDescricao
    case pLabelAvaliarVeiculo
    case pLabelAvaliarVeiculoDescricao
    case pBotaoPerfilMeusDados
    case pBotaoPerfilMeuEndereco
    
    // Meus Dados
    case pTituloMeusDados
    case pSubtituloMeusDados
    case pCampoMeusDadosEmail
    case pCampoMeusDadosNomeCompleto
    case pCampoMeusDadosCPF
    case pCampoMeusDadosDtNascimento
    case pCampoMeusDadosCelular
    case pBotaoMeusDadosSalvar
    
    // Meu Endereço
    case pTituloMeuEndereco
    case pSubtituloMeuEndereco
    case pCampoMeuEnderecoCep
    case pBotaoMeuEnderecoNaoSeiMeuCep
    case pCampoMeuEnderecoEndereco
    case pCampoMeuEnderecoNumero
    case pCampoMeuEnderecoBairro
    case pCampoMeuEnderecoComplemento
    case pCampoMeuEnderecoCidade
    case pCampoMeuEnderecoEstado
    
    // Meu Endereço Buscar Cep
    case pTituloMeuEnderecoBuscarCep
    case pTituloMeuEnderecoBuscarCepEnderecos
    
    // Consultar
    case cTituloConsultarDescricao
    case cTituloConsultar
    case cCampoPlaca
}


extension StringIdentifier {
    
    func getString() -> String {
        return String(withCustomIdentifier: self)
    }
}
