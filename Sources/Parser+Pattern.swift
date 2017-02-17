//
//  Parser+Pattern.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 14/02/2017.
//
//

extension Parser {

    public func then(_ pattern: Pattern) -> Parser {
        return Parser { text in
            guard
                let r0 = self.parse(text),
                let s1 = pattern.parseSuffix(of: text, after: r0.suffixIndex)
                else { return nil }

            return Result(value: r0.value, suffixIndex: s1)
        }
    }

    public func and<OtherValue>(_ other: Parser<OtherValue>) -> Parser<(Value, OtherValue)> {
        return Parser<(Value, OtherValue)> { text in
            guard
                let r0 = self.parse(text),
                let r1 = other.parseSuffix(of: text, after: r0.suffixIndex)
                else { return nil }

            return ParseResult<(Value, OtherValue)>(
                value: (r0.value, r1.value),
                suffixIndex: r1.suffixIndex
            )
        }
    }
}

extension Pattern {

    public func then<NewValue>(_ parser: Parser<NewValue>) -> Parser<NewValue> {
        return Parser<NewValue> { text in
            guard
                let s0 = self.parse(text),
                let r1 = parser.parseSuffix(of: text, after: s0)
                else { return nil }
            return r1
        }
    }

    public func then(_ pattern: Pattern) -> Pattern {
        return Pattern { text in
            guard
                let s0 = self.parse(text),
                let s1 = pattern.parseSuffix(of: text, after: s0)
                else { return nil }
            return s1
        }
    }
}

public func + <LHS, RHS>(lhs: Parser<LHS>, rhs: Parser<RHS>) -> Parser<(LHS, RHS)> {
    return lhs.and(rhs)
}

public func + <Value>(lhs: Pattern, rhs: Parser<Value>) -> Parser<Value> {
    return lhs.then(rhs)
}

public func + <Value>(lhs: Parser<Value>, rhs: Pattern) -> Parser<Value> {
    return lhs.then(rhs)
}

public func + (lhs: Pattern, rhs: Pattern) -> Pattern {
    return lhs.then(rhs)
}