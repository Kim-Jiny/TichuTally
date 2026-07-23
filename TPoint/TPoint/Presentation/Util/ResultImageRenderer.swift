//
//  ResultImageRenderer.swift
//  TPoint
//
//  게임 결과를 워터마크가 포함된 공유용 이미지로 렌더링한다.
//

import UIKit

enum ResultImageRenderer {

    static func render(
        winnerLine: String,
        teamAName: String,
        teamAScore: Int,
        teamAColor: UIColor,
        teamBName: String,
        teamBScore: Int,
        teamBColor: UIColor,
        winnerColor: UIColor,
        roundsText: String,
        appName: String
    ) -> UIImage {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            UIColor(red: 0x17 / 255, green: 0x18 / 255, blue: 0x1C / 255, alpha: 1).setFill()
            cg.fill(CGRect(origin: .zero, size: size))

            // 지정한 중심(centerX, centerY)에 텍스트를 그린다
            func draw(_ text: String, centerY: CGFloat, font: UIFont, color: UIColor, centerX: CGFloat = 540) {
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let str = NSAttributedString(string: text, attributes: attrs)
                let sz = str.size()
                str.draw(at: CGPoint(x: centerX - sz.width / 2, y: centerY - sz.height / 2))
            }

            // 트로피
            draw("🏆", centerY: 220, font: .systemFont(ofSize: 150), color: .white)

            // 우승 문구 (너무 길면 축소)
            var winFont = UIFont.systemFont(ofSize: 80, weight: .bold)
            while (winnerLine as NSString).size(withAttributes: [.font: winFont]).width > size.width - 100
                    && winFont.pointSize > 40 {
                winFont = .systemFont(ofSize: winFont.pointSize - 4, weight: .bold)
            }
            draw(winnerLine, centerY: 440, font: winFont, color: winnerColor)

            // 점수 (두 컬럼)
            let nameFont = UIFont.systemFont(ofSize: 44, weight: .bold)
            let scoreFont = UIFont.systemFont(ofSize: 120, weight: .bold)
            let grey = UIColor(white: 0.6, alpha: 1)

            draw(ellipsize(teamAName, font: nameFont, maxWidth: 400), centerY: 610, font: nameFont, color: teamAColor, centerX: 300)
            draw("\(teamAScore)", centerY: 730, font: scoreFont, color: teamAColor, centerX: 300)
            draw(ellipsize(teamBName, font: nameFont, maxWidth: 400), centerY: 610, font: nameFont, color: teamBColor, centerX: 780)
            draw("\(teamBScore)", centerY: 730, font: scoreFont, color: teamBColor, centerX: 780)
            draw("vs", centerY: 720, font: .systemFont(ofSize: 52), color: grey)

            // 라운드 수
            draw(roundsText, centerY: 890, font: .systemFont(ofSize: 46), color: grey)

            // 하단 앱 이름 워터마크
            draw(appName, centerY: 1000, font: .systemFont(ofSize: 48, weight: .bold), color: UIColor(white: 0.42, alpha: 1))
        }
    }

    private static func ellipsize(_ text: String, font: UIFont, maxWidth: CGFloat) -> String {
        if (text as NSString).size(withAttributes: [.font: font]).width <= maxWidth { return text }
        var end = text.count
        while end > 1 {
            let candidate = String(text.prefix(end)) + "…"
            if (candidate as NSString).size(withAttributes: [.font: font]).width <= maxWidth {
                return candidate
            }
            end -= 1
        }
        return text
    }
}
