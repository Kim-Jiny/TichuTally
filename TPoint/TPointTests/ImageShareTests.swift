//
//  ImageShareTests.swift
//  TPointTests
//
//  결과 공유 이미지 렌더링 검증
//

import Testing
import UIKit
@testable import TPoint

struct ImageShareTests {

    @Test func rendersResultImage() throws {
        let blue = UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1)
        let red = UIColor(red: 0.90, green: 0.22, blue: 0.21, alpha: 1)
        let img = ResultImageRenderer.render(
            winnerLine: "SharksgEagles Wins!",
            teamAName: "SharksgEagles",
            teamAScore: 600,
            teamAColor: blue,
            teamBName: "B팀",
            teamBScore: 0,
            teamBColor: red,
            winnerColor: blue,
            roundsText: "3라운드",
            appName: "Tichu Tally"
        )
        #expect(img.size == CGSize(width: 1080, height: 1080))
        let data = try #require(img.pngData())
        #expect(data.count > 1000)

        // 시각 검증을 위해 문서 디렉터리에 저장
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try data.write(to: dir.appendingPathComponent("test_result.png"))
    }
}
