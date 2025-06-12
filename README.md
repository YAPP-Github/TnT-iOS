# TnT
<img src="https://raw.githubusercontent.com/YAPP-Github/TnT-iOS/refs/heads/TNT-294-ReadMe/TnT/Photos/TNT_%E1%84%80%E1%85%B3%E1%84%85%E1%85%A2%E1%84%91%E1%85%B5%E1%86%A8%E1%84%8B%E1%85%B5%E1%84%86%E1%85%B5%E1%84%8C%E1%85%B5.png" >
  
### # 트레이너와 트레이니를 연결하다
  
PT 효과가 미미하거나, 꾸준히 PT를 지속하기 어려웠나요? 트레이너와 트레이니 사이의 체계적인 소통과 효유적인 PT 운영을 직접 경험하세요 :)
  
💪🏻 트레이너는 체계적인 회원 관리를, 트레이니는 효율적인 기록을!  
🏋 TnT와 함께 트레이너와 트레이니의 케미를 터트려보세요!  
  
-------
### Develpoment Environment
```
Minimum Deployments: iOS 17.0
Xocde Version: 16.0.1
Tuist Version: 4.37.0
```

**외부 라이브러리**
```
kakao-ios-sdk
KingFisher
FirebaseMessaging
ComposableArchitecture
FSCalendar
```

---
### Skill Stack
- Development: SwiftUI + Tuist + Modular Architecture
- Modular Architecture : Clean Architecture 기준 레이어별 모듈화
- Architecture : Clean Architecture + TCA
---
  
### Architecture (Clean Architecture + TCA)

<img src="https://raw.githubusercontent.com/YAPP-Github/TnT-iOS/refs/heads/TNT-294-ReadMe/TnT/Photos/Architecture.png">

-------
### Layer 구현 내용
**Application Layer**
- AppDelegate, SceneDelegate 위치  
- 애플리케이션의 진입점으로써 실행과 관련된 작업을 처리함 

`Data Layer`
- 외부 데이터 소스와의 상호작용을 담당하는 레이어  
- Network / Local(KeyChain) 로 나누어 외부 데이터를 관리함
- DTO로 받아오며 Mapper를 통해 앱 내부에 맞는 데이터로 변환하여 사용  
- Moya의 로직을 URLSession에 점목하여 Interceptor와 Logger를 구현함
  
`Domain Layer`
- 비즈니스 로직을 처리하는 애플리케이션의 핵심 레이어로, 앱의 도메인 규칙을 정의함
- Entity: 비즈니스 도메인의 핵심 모델이며, UI나 외부 데이터 소스와 독립적
- UseCase: 특정 비즈니스 규칙을 수행하는 인터페이스로, Repository를 통해 데이터를 가져오거나 가공하여 Presentation Layer에서 사용할 수 있도록 구현함
- Repository Protocol: 데이터 접근 방식(Network, Local Storage 등)을 추상화하여, Data Layer의 구현과 분리된 형태로 유지시킴
  
`Presentation Layer`
- UI와 관련된 모든 요소를 담당하는 레이어로, **SwiftUI + TCA** 으로 구성됨
- **View (SwiftUI)**: Store에서 제공하는 상태를 기반으로 UI를 렌더링하며, 유저 인터랙션을 Action으로 변환하여 Store에 전달함
- **Feature (Reducer + State + Action)**: 각 화면을 하나의 Feature로 구성하고, Reducer에서 State와 Action을 관리하며 비즈니스 로직을 UseCase에 위임함
- **Navigation**: TCA의 Reducer 기반 네비게이션을 활용하여 화면 전환을 관리하며, 네비게이션 상태(Path, Stack)를 State로 유지함
  
`DIContainer`
- DIContainer는 앱 전반에서 **객체의 생성과 의존성 주입을 관리함**
- 각 레이어의 객체들이 직접 인스턴스를 생성하는 대신, DIContainer를 통해 필요한 의존성을 주입받도록 설계하여 **클린 아키텍처의 원칙(의존성 역전 원칙, DIP)** 을 따를 수 있도록함
- Repository, UseCase, Reducer(Store) 등과 같은 핵심 객체들을 DIContainer에서 생성하고 관리하며, Environment 또는 Resolver를 통해 필요한 객체를 주입받아 사용
  
`Design System`
- 디자인과 관련된 파일, 소스들이 모여있는 모듈  
- 비즈니스 로직과 연관 없이 디자인만 정의되어 있는 모듈

---
### Main Features
- 로그인
    - 소셜로그인 지원 (카톡 / 애플)
- 트레이너
	- 홈
		- 수업 추가 및 일정 확인
	    - 수업 관리
    - 피드백
	    - 트레이니가 보낸 피드백을 확인하고 피드백 전송
	- 회원 목록
		- 회원을 연결 및 해제
		- 회원 초대
	- 내정보
		- 로그아웃 및 탈퇴
		- 내정보 확인
- 트레이니
	- 홈
		- 수업 관리 및 운동 기록
		- 식단 기록
	-  내정보
		- 로그아웃 및 탈퇴
		- 내정보 확인

---
### App Images

| 트레이니 홈                                                                                                                                                                                                                                   | `트레이너 홈`                                                                                                                                                                                                                                             | `내정보`                                                                                                                                                                                                                                                                         | `트레이니 식단기록`                                                                                                                                                                                                                                                                                                      |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://raw.githubusercontent.com/YAPP-Github/TnT-iOS/refs/heads/TNT-294-ReadMe/TnT/Photos/%E1%84%90%E1%85%B3%E1%84%85%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%82%E1%85%B5_%E1%84%92%E1%85%A9%E1%86%B7.PNG" width="143" height="300"> | <img src="https://raw.githubusercontent.com/YAPP-Github/TnT-iOS/refs/heads/TNT-294-ReadMe/TnT/Photos/%E1%84%90%E1%85%B3%E1%84%85%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%82%E1%85%A5_%E1%84%92%E1%85%A9%E1%86%B7.PNG" width="143" height="300"><br><br><br> | <img src="https://raw.githubusercontent.com/YAPP-Github/TnT-iOS/refs/heads/TNT-294-ReadMe/TnT/Photos/%E1%84%90%E1%85%B3%E1%84%85%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%82%E1%85%A5_%E1%84%82%E1%85%A2%E1%84%8C%E1%85%A5%E1%86%BC%E1%84%87%E1%85%A9.jpeg" width="143" height="300"> | <img src="https://raw.githubusercontent.com/YAPP-Github/TnT-iOS/refs/heads/TNT-294-ReadMe/TnT/Photos/%E1%84%90%E1%85%B3%E1%84%85%E1%85%A6%E1%84%82%E1%85%B5%E1%84%8B%E1%85%B5_%E1%84%89%E1%85%B5%E1%86%A8%E1%84%83%E1%85%A1%E1%86%AB%E1%84%80%E1%85%B5%E1%84%85%E1%85%A9%E1%86%A8.PNG" width="143" height="300"> |
|                                                                                                                                                                                                                                          |                                                                                                                                                                                                                                                      |                                                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                                  |
