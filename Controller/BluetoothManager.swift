import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private var obd2Peripheral: CBPeripheral?
    
    override init() {
        super.init()
        // 중앙 매니저를 초기화하고, 델리게이트를 self로 설정
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        // Bluetooth가 켜져 있는지 확인한 후 스캔 시작
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on.")
            return
        }
        // 특정 서비스 필터 없이 주변 장치를 스캔 시작
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning() {
        // 주변 장치 스캔 중지
        centralManager.stopScan()
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Bluetooth 상태 처리
        switch central.state {
        case .unknown:
            print("Bluetooth status is unknown.")
        case .resetting:
            print("Bluetooth is resetting.")
        case .unsupported:
            print("Bluetooth is not supported on this device.")
        case .unauthorized:
            print("Bluetooth is not authorized.")
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .poweredOn:
            print("Bluetooth is powered on and ready.")
            // Bluetooth가 켜진 후 스캔 시작
            startScanning()
        @unknown default:
            print("A new state is available that is not handled.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // 발견된 주변 장치 로그
        print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
        // 주변 장치가 OBD-II 장치인지 이름을 통해 확인
        if peripheral.name?.contains("OBD") == true {
            // OBD-II 장치를 찾았을 경우, 스캔 중지 후 연결 시도
            obd2Peripheral = peripheral
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 연결 성공 로그
        print("Connected to \(peripheral.name ?? "an OBD-II device")")
        obd2Peripheral = peripheral
        // 이후 통신을 처리하기 위해 주변 장치의 델리게이트를 self로 설정
        obd2Peripheral?.delegate = self
        // 주변 장치가 제공하는 서비스 발견
        obd2Peripheral?.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // 연결 실패 로그
        print("Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown error")")
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            // 서비스 발견 중 오류 로그
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        // 발견된 서비스 반복 처리
        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered service: \(service.uuid)")
            // 각 서비스에 대한 특성 발견
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            // 특성 발견 중 오류 로그
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        // 발견된 특성 반복 처리
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid)")
            // 필요에 따라 특성에 쓰거나 구독하는 로직 추가 가능
        }
    }
}
