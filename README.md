# Car Diagnostic & Maintenance App

## 개요

이 프로젝트는 차량의 주요 데이터를 분석하여 실시간으로 상태를 진단하고 사용자에게 경고 및 유지 관리 정보를 제공하는 iOS 기반 차량 진단 앱입니다. 이 앱은 OBD-II 연결을 통해 차량의 상태를 모니터링하고, 유지 관리 팁과 경고 알림을 통해 사용자가 차량을 효율적으로 관리할 수 있도록 돕습니다.

**주요 특징:**
- 차량 데이터 실시간 모니터링
- 경고 알림 시스템
- 진단 이력 및 유지 관리 팁 제공
- PDF 보고서 생성 및 공유
- OBD-II Bluetooth 연결 지원

## 주요 기능

1. **실시간 차량 데이터 모니터링**
   - 엔진 온도, 배터리 레벨, 타이어 공기압 등의 상태를 시각적으로 제공합니다.
   - 문제가 발생하면 텍스트 색상이 변하고, 경고 메시지와 알림을 통해 사용자에게 통지합니다.

2. **세부 진단 항목**
   - 엔진 온도, 배터리 레벨, 연료 효율, 공기압, 배터리 전압, 연료 레벨, 흡기 온도, 엔진 부하, 산소 농도 등 다양한 진단 항목을 제공합니다.

3. **진단 히스토리 관리**
   - 각 진단 항목의 이력을 시간별로 기록하며, 최대 10개의 최신 기록을 제공합니다.

4. **경고 히스토리 관리**
   - 차량에서 발생한 경고 메시지를 최신 순으로 최대 50개까지 저장하고 표시합니다.

5. **PDF 리포트 생성**
   - 차량 상태에 대한 요약 정보를 PDF 파일로 생성하여 공유할 수 있습니다.
   - PDF에는 엔진 온도, 배터리 레벨 등의 변화 그래프가 포함됩니다.

6. **OBD-II Bluetooth 연결**
   - CoreBluetooth를 사용하여 OBD-II 장치를 찾고 연결하여 차량 데이터를 수집합니다.

## 기술 스택

- **프로그래밍 언어**: Swift
- **UI 프레임워크**: SwiftUI
- **저장소 관리**: Core Data (진단 이력 관리)
- **Bluetooth 연결**: CoreBluetooth (OBD-II 장치 연결)
- **알림 시스템**: NotificationCenter, UserNotifications

## 설치 및 실행 방법

1. **Clone Repository**
   ```sh
   git clone https://github.com/yourusername/car-diagnostic-app.git
   ```

2. **프로젝트 열기**
   - Xcode에서 `CarDiagnosticApp.xcodeproj` 파일을 엽니다.

3. **의존성 설치**
   - 필요한 경우 CocoaPods 또는 Swift Package Manager를 사용해 의존성을 설치합니다.

4. **시뮬레이션 및 실행**
   - Xcode의 시뮬레이터 또는 실제 iOS 디바이스에서 프로젝트를 빌드 및 실행합니다.

## 주요 화면 설명

1. **홈 화면**
   - 차량 상태 요약 및 경고 메시지 표시.

2. **세부 진단 화면**
   - 차량의 다양한 데이터 항목을 상세히 표시.

3. **진단 히스토리 화면**
   - 이전 진단 내역을 시간 순으로 보여줍니다.

4. **설정 화면**
   - 사용자 맞춤형 알림 임계값 설정 기능.

5. **경고 히스토리 화면**
   - 발생한 경고 기록을 최신순으로 표시.

## 기술적 도전 과제와 해결 방안

1. **OBD-II Bluetooth 안정성**
   - Bluetooth 연결 과정에서 안정성을 높이기 위해 예외 처리를 추가하고, 재시도 메커니즘을 구현했습니다.

2. **실시간 데이터 업데이트 최적화**
   - Combine 프레임워크를 사용하여 실시간으로 차량 데이터를 효율적으로 업데이트.

## 향후 발전 방향

- **AI 기반 예측 진단**: 머신러닝을 적용하여 차량의 잠재적 문제를 미리 예측하는 기능 추가.
- **UI/UX 개선**: 사용자 인터페이스를 더욱 직관적으로 개선하고 애니메이션 효과 추가.
- **OBD-II 장치와의 테스트 확대**: 실제 차량 환경에서의 테스트를 통해 데이터 수집의 정확성을 높임.
