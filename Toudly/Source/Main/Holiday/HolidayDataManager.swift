//
//  HolidayDataManager.swift
//  Toudly
//
//  Created by 김지훈 on 2023/01/12.
//

import Alamofire

class HolidayDataManager {
    func getHolidayInfo(year: Int, month: String) {
        AF.request("\(Constant.HOLIDAY_BASE_URL)/getHoliDeInfo?serviceKey=\(Constant.HOLIDAY_SERVICE_KEY)&solYear=\(year)&solMonth=\(month)&_type=json", method: .get, parameters: nil, encoding: JSONEncoding(), headers: nil)
            .validate()
            .responseDecodable(of: HolidayResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    // 성공했을 때
                    print("성 공")
                    let holidayResultResponse = response.response
                    if holidayResultResponse.header.resultCode == .success {
                        print(holidayResultResponse.body.items)
                    }
                    // 실패했을 때
                    else {
                        print("실 패")
                    }
                case .failure(let error):
                    print("서버와의 연결이 원활하지 않습니다")
                    print(error.localizedDescription)
                }
            }
    }
}

