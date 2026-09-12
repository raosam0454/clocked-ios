//
//  EmployerRepository.swift
//  Clocked
//
//  Created by Sumangala Rao on 9/9/2026.
//
import Foundation

/// Where the student's employers are kept.
protocol EmployerRepository: AnyObject {
    func allEmployers() -> [Employer]
    func employer(with id: EmployerIdentifier) -> Employer?
    func add(_ employer: Employer)
}

final class InMemoryEmployerRepository: EmployerRepository {
    private var employers: [Employer]

    init(employers: [Employer] = []) {
        self.employers = employers
    }

    func allEmployers() -> [Employer] {
        employers
    }

    func employer(with id: EmployerIdentifier) -> Employer? {
        employers.first { $0.id == id }
    }

    func add(_ employer: Employer) {
        employers.append(employer)
    }
}
