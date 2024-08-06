//
//  CDAction.swift
//  Carbon
//
//  Created by Jason Jobe on 8/6/24.
//
// https://deepblue.lib.umich.edu/bitstream/handle/2027.42/30278/0000679.pdf;jsessionid=A710F9786B0DBF89C9EBFF5355A834F6?sequence=1
/**
 ## CDAction - Primitive Real-World Actions
 Inspired by (Schank's Conceptual Dependency Theory)[https://en.wikipedia.org/wiki/Conceptual_dependency_theory]
 
 #### Operations
 
 - MONEY (Actor, Amount, From, To)
 - Transfer of an cash/money (e.g., possession, ownership)
 - Special case because it is so common - NOT part of Schank's original
 - Example: "John gave Mary 5 dollars" (John MONEY 5 dollars From John To Mary)
 
 - ATRANS (Actor, Object, From, To)
    - Transfer of an abstract relationship (e.g., possession, ownership)
    - Example: "John gave Mary the book" (John ATRANS book From John To Mary)
 
 - PTRANS (Actor, Object, From, To)
    - Transfer of physical location of an object
    - Example: "John went to the store" (John PTRANS John From somewhere To store)
 
 - MTRANS (Actor, Information, From, To)
    - Transfer of mental information
    - Example: "John told Mary the news" (John MTRANS news From John's memory To Mary)
 
 - MBUILD (Actor, Information, From)
    - Building new information from old
    - Example: "John solved the problem" (John MBUILD solution From problem-information)
 
 - ATTEND (Actor, Subject)
    - Focusing of an agent/person towards a stimulus
    - Example: "John looked at the painting" (John ATTEND painting)
 
 - CONSUME (Actor, Object)
    - Ingesting something into the body of an actor
    - Example: "John ate the apple" (John INGEST apple To mouth/stomach)
 
 - PRODUCE (Actor, Object)
    - Expelling something from the body of an actor
    - Example: "John spit out the seeds" (John EXPEL seeds From mouth)
 
 NOTE: A few tweaks to the orginal include
 - added MONEY as special and very common case
 - renamed INGEST to CONSUME and removed "body part" parameter
 - renamed EXPEL to PRODUCE and removed "body part" parameter
 - SPEAK, PROPEL, MOVE, and GRASP are not supported in code
 
 - SPEAK (Actor, Sound, To)
    - Production of sound
    - Example: "John said 'hello'" (John SPEAK "hello" To audience)
 
 - PROPEL (Actor, Object, Direction)
    - Application of physical force to an object
    - Example: "John pushed the cart" (John PROPEL cart Direction forward)
 
 - MOVE (Actor, BodyPart, From, To)
    - Movement of a body part by an actor
    - Example: "John raised his arm" (John MOVE arm From down-position To up-position)
 
 - GRASP (Actor, Object, BodyPart)
    - Grasping of an object by an actor
    - Example: "John grabbed the ball" (John GRASP ball With hand)
 */
import Foundation

/**
 A `CDAction` is a primative real-world action expressed semantically.
 These are primarily some form of transfer of money, information, ownership,
 and goods or the production or consumption of some product, good, or service.
 
It has its origins in Schank's Conceptual Dependency Theory.
- MONEY   (amount: Amount, from: Parameter, to: Parameter)
- ATRANS  (object: Parameter, from: Parameter, to: Parameter)
- PTRANS  (object: Parameter, from: Parameter, to: Parameter)
- MTRANS  (information: Parameter, from: Parameter, to: Parameter)
- MBUILD  (information: Parameter, from: Parameter)
- ATTEND  (subject: Parameter)
- CONSUME (object: Parameter, to: Parameter)
- PRODUCE (object: Parameter, from: Parameter)
 */
public struct CDAction: Identifiable, Codable {
    public typealias Parameter = String
    public typealias Amount = Double
    
    public let id: MID64
    public let actor: MID64
    public let scope: MID64
    public let timestamp: Date
    public let action: Action
    public let memo: String?
    
    public init(id: MID64 = .init(), actor: MID64, scope: MID64 = .null, timestamp: Date = Date(), memo: String? = nil, action: Action) {
        self.id = id
        self.actor = actor
        self.scope = scope
        self.timestamp = timestamp
        self.memo = memo
        self.action = action
    }
}

extension CDAction {
    /// **Cases**: money, atrans, mtrans, ptrans, mbuild, attend, consume, produce
    public enum Action: Codable {
        /// MONEY   (amount: Amount, from: Parameter, to: Parameter)
        case money   (amount: Amount, from: Parameter, to: Parameter)
        /// ATRANS  (object: Parameter, from: Parameter, to: Parameter)
        case atrans  (object: Parameter, from: Parameter, to: Parameter)
        /// PTRANS  (object: Parameter, from: Parameter, to: Parameter)
        case ptrans  (object: Parameter, from: Parameter, to: Parameter)
        /// MTRANS  (information: Parameter, from: Parameter, to: Parameter)
        case mtrans  (information: Parameter, from: Parameter, to: Parameter)
        /// MBUILD  (information: Parameter, from: Parameter)
        case mbuild  (information: Parameter, from: Parameter)
        /// ATTEND  (subject: Parameter)
        case attend  (subject: Parameter)
        /// CONSUME (object: Parameter, to: Parameter)
        case consume (object: Parameter, to: Parameter)
        /// PRODUCE (object: Parameter, from: Parameter)
        case produce (object: Parameter, from: Parameter)
    }
    
}
