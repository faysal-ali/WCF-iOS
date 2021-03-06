/**
 * Copyright © 2019 Aga Khan Foundation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

import Foundation

struct Participant {
  let id: Int?                                                                  // swiftlint:disable:this identifier_name line_length
  let fbid: String
  let team: Team?
  let events: [Event]?
  let preferredCause: Cause?
  let records: [Record]?
  var teamMembers = [Participant]()

  init?(json: JSON?) {
    guard let json = json else { return nil }

    guard let fbid = json["fbid"]?.stringValue else { return nil }
    self.fbid = fbid

    self.id = json["id"]?.intValue
    self.team = Team(json: json["team"])
    self.events = json["events"]?.arrayValue?.compactMap { Event(json: $0) }
    self.preferredCause = Cause(json: json["cause"])
    self.records = json["records"]?.arrayValue?.compactMap { Record(json: $0) }
  }

  public var currentEvent: Event? {
    return self.events?.filter { $0.challengePhase.end > Date(timeIntervalSinceNow: 0) }.first
  }

  public var currentTeamProgressInMiles: Int {
    return (teamMembers.reduce(0, { (total, member) -> Int in
        guard let records = member.records else { return total + 0 }
        var sum = 0
        for record in records {
          sum += (record.distance ?? 0)
        }
        return total + sum
      }))/2000
  }

  public var totalTeamCommitmentInMiles: Int {
    return (teamMembers.reduce(0) { (total, member) -> Int in
      return total + (member.currentEvent?.commitment?.steps ?? 0)
    })/2000
  }

}
