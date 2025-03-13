//
//  UserPolicy.swift
//  Domain
//
//  Created by 박민서 on 1/17/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

struct UserPolicy {
    /// 사용자 이름 최대 길이 제한 (공백 포함)
    static let maxNameLength: Int = 15
    
    /// 사용자 이름 검증 - 한글/영어/공백만 허용 (특수문자 불가)
    static let userNameInput: PolicyInputInfo = .init(
        textValidation: { TextValidator.isValidInput($0, maxLength: maxNameLength, regexPattern: "^(?!\\s*$)[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z ]*$") },
        isRequired: true
    )
    
    /// 생년월일 입력 검증 (YYYY/MM/DD 형식)
    static let birthDateInput: PolicyInputInfo = .init(
        textValidation: { TextValidator.isValidDate(text: $0, format: .yyyyMMddSlash) },
        isRequired: false
    )
    
    /// 키 입력 검증 (정수 3자리)
    static let heightInput: PolicyInputInfo = .init(
        textValidation: { TextValidator.isValidInput($0, maxLength: 3, regexPattern: #"^\d{3}$"#) },
        isRequired: false
    )
    
    /// 몸무게 입력 검증 (정수 3자리 + 소수점 1자리)
    /// 정수 최소 2자리 이상, 소수점 1자리까지만
    static let weightInput: PolicyInputInfo = .init(
        textValidation: { TextValidator.isValidInput($0, maxLength: 5, regexPattern: #"^\d{2,3}(\.\d{1})?$"#) },
        isRequired: false
    )
    
    /// 주의사항 최대 길이 제한 (공백 포함)
    static let maxPrecautionLength: Int = 100
    
    /// 주의사항 입력 검증 (100자 제한, 외 제한 없음. 옵션)
    static let precautionInput: PolicyInputInfo = .init(
        textValidation: { $0.count <= maxPrecautionLength },
        isRequired: false
    )
}
