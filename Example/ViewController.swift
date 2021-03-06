//
//  ViewController.swift
//  Example
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxSwift
import RxCocoa
import RxDataSources

struct NumberSection {
    var header: String
    var numbers: [IntItem]

    var updated: Date

    init(header: String, numbers: [Item], updated: Date) {
        self.header = header
        self.numbers = numbers
        self.updated = updated
    }
}

struct IntItem {
    let number: Int
    let date: Date
}

extension NumberSection: AnimatableSectionModelType {
    typealias Item = IntItem
    typealias Identity = String

    var items: [IntItem] {
        return numbers
    }
    var identity: String { return header }

    init(original: NumberSection, items: [Item]) {
        self = original
        self.numbers = items
    }
}

extension IntItem: IdentifiableType, Equatable {
    typealias Identity = Int
    var identity: Int {
        return number.hashValue
    }
}

func ==(lhs: IntItem, rhs: IntItem) -> Bool {
    return lhs.date == rhs.date && lhs.number == rhs.number
}

class ViewController: UIViewController {

    let tableNode = ASTableNode()
    private let dataSource = RxASTableAnimatedDataSource<NumberSection>()

    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubnode(tableNode)

        dataSource.configureCell = { (_, tv, ip, i) in
            let cell = ASTextCellNode()
            cell.text = "\(i.number)"
            return cell
        }

        dataSource.titleForHeaderInSection = { (dataSource, section) -> String? in
            return dataSource[section].header
        }

        Observable<Int>
            .interval(2.0, scheduler: MainScheduler.instance)
            .map { _ in
                var sectionIndex = Set<Int>()
                var section = [NumberSection]()

                let numberSections = Int(arc4random_uniform(5)) + 2

                while sectionIndex.count < numberSections {
                    let random = Int(arc4random_uniform(9))
                    guard !sectionIndex.contains(random) else { continue }

                    section.append(_initialValue[random])
                    sectionIndex.insert(random)
                }

                return section
            }
            .bind(to: tableNode.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableNode.frame = self.view.bounds
    }
}

func $(_ numbers: [Int]) -> [IntItem] {
    return numbers.map { IntItem(number: $0, date: Date()) }
}

let _initialValue: [NumberSection] = [
    NumberSection(header: "section 1", numbers: $([1, 2, 3]), updated: Date()),
    NumberSection(header: "section 2", numbers: $([4, 5, 6]), updated: Date()),
    NumberSection(header: "section 3", numbers: $([7, 8, 9]), updated: Date()),
    NumberSection(header: "section 4", numbers: $([10, 11, 12]), updated: Date()),
    NumberSection(header: "section 5", numbers: $([13, 14, 15]), updated: Date()),
    NumberSection(header: "section 6", numbers: $([16, 17, 18]), updated: Date()),
    NumberSection(header: "section 7", numbers: $([19, 20, 21]), updated: Date()),
    NumberSection(header: "section 8", numbers: $([22, 23, 24]), updated: Date()),
    NumberSection(header: "section 9", numbers: $([25, 26, 27]), updated: Date()),
    NumberSection(header: "section 10", numbers: $([28, 29, 30]), updated: Date())
]
