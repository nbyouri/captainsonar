functor
import
   Input
   System
   OS %rand
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream

   InitState
   InitStateEnemies
   UpdateState
   MapRandomPos
   MapIsWater
   
   InitPosition
   Move
   Dive
   CanMove
   ChargeItem
   FireItem
   FireMine
   IsSurface
   SayMove
   SaySurface
   SayCharge
   SayMinePlaced
   SayMissileExplode
   SayMineExplode
   SayPassingDrone
   SayAnswerDrone
   SayPassingSonar
   SayAnswerSonar
   SayDeath
   SayDamageTaken

   Directions

   StateModification

   NotOnPath
in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{InitState ID Color}
      fun{Sub State N} NewState StateEn in
	 if N == 0 then
	    State
	 else
	    StateEn = {UpdateState State.enemies [N#enemy(pos:null spotted:false)]}
	    NewState = {UpdateState State [enemies#StateEn]}
	    {Sub NewState N-1}
	 end
      end
      MidState
      NewState
   in
      MidState = state(
		    id:id(id:ID color:Color name:'SeekDestroy')
		    dead:false
		    hp:Input.maxDamage
		    missileCharge:0
		    mineCharge:0
		    sonarCharge:0
		    droneCharge:0
		    enemies:data(1:null)
		    surf:true
		    visited:nil
		    mode:seek
		    target:null
		    )
      NewState = {Sub MidState Input.nbPlayer}
      NewState
   end
   
   fun{UpdateState State L}
      {AdjoinList State L}
   end

   fun{MapRandomPos}
      pt(x:({OS.rand} mod Input.nRow + 1) y:({OS.rand} mod Input.nColumn + 1))
   end
   
   fun{MapIsWater Pos}
      {List.nth {List.nth Input.map Pos.x} Pos.y} == 0
   end

   Directions = [surface east west south north]

%%%%%%%

   %les fonctions ci-dessous représentent le comportement du sub
   
   fun{InitPosition State ID Position}
      fun{NewPos} Pos in
	 Pos = {MapRandomPos}
	 if {MapIsWater Pos} then
	    Pos
	 else
	    {NewPos}
	 end
      end
      NewState
      RetPos
   in
      RetPos = {NewPos}
      NewState = {UpdateState State [visited#[RetPos] pos#RetPos]}
      ID = NewState.id
      Position = NewState.pos
      NewState
   end

   fun{CanMove Pos}
      if (Pos.x =< Input.nRow andthen Pos.y =< Input.nColumn andthen Pos.x > 0 andthen Pos.y > 0) then
	 {MapIsWater Pos}
      else
	 false
      end
   end

   fun{NotOnPath Pos Visited}
      case Visited of nil then true
      [] H|T then 
	 if(H == Pos) then
	    false
	 else
	    {NotOnPath Pos T}
	 end
      end		     
   end
   
   fun{Move State ID Position Direction} NewState
      fun{NewPos} Pos Direction in
	 Direction = {Nth Directions ({OS.rand} mod ({Length Directions}) + 1 )}
	 case Direction of
	 east then Pos = pt(x:(State.pos.x) y:(State.pos.y+1))
	 [] north then Pos = pt(x:(State.pos.x-1) y:(State.pos.y))
	 [] south then Pos = pt(x:(State.pos.x+1) y:(State.pos.y))
	 [] west then Pos = pt(x:(State.pos.x) y:(State.pos.y-1))
	 [] surface then Pos = State.pos
	 end
	 case Direction of surface then Pos#Direction
	 else  
	    if {CanMove Pos} andthen {NotOnPath Pos State.visited} then
	    Pos#Direction
	    else
	    {NewPos}
	    end
	 end
      end

      fun{FollowPos Call} Pos Direction in
	 case Call of firstCall then
	 if (State.pos.x > State.enemies.(State.target).pos.x) then
	    Direction = south
	 elseif (State.pos.x < State.enemies.(State.target).pos.x) then
	    Direction = north
	 else
	    if (State.pos.y > State.enemies.(State.target).pos.y) then
	       Direction = west
	    else
	       Direction = east
	    end
	 end
	 case Direction of
	 east then Pos = pt(x:(State.pos.x) y:(State.pos.y+1))
	 [] north then Pos = pt(x:(State.pos.x-1) y:(State.pos.y))
	 [] south then Pos = pt(x:(State.pos.x+1) y:(State.pos.y))
	 [] west then Pos = pt(x:(State.pos.x) y:(State.pos.y-1))
	 [] surface then Pos = State.pos
	 end
	 case Direction of surface then Pos#Direction
	 else  
	    if {CanMove Pos} andthen {NotOnPath Pos State.visited} then
	    Pos#Direction
	    else
	    {FollowPos secondCall}
	    end
	 end
	 [] secondcall then
	    if (State.pos.y > State.enemies.(State.target).pos.y) then
	       Direction = west
	    elseif (State.pos.y < State.enemies.(State.target).pos.y) then
	       Direction = east
	    else
	       if (State.pos.x > State.enemies.(State.target).pos.x) then
		  Direction = south
	       else
		  Direction = north
	       end
	    end
	    case Direction of
	       east then Pos = pt(x:(State.pos.x) y:(State.pos.y+1))
	    [] north then Pos = pt(x:(State.pos.x-1) y:(State.pos.y))
	    [] south then Pos = pt(x:(State.pos.x+1) y:(State.pos.y))
	    [] west then Pos = pt(x:(State.pos.x) y:(State.pos.y-1))
	    [] surface then Pos = State.pos
	    end
	    case Direction of surface then Pos#Direction
	    else  
	       if {CanMove Pos} andthen {NotOnPath Pos State.visited} then
		  Pos#Direction
	       else
		  {NewPos}
	       end
	    end
	 else
	    {NewPos}
	 end
      end
      RetVal
   in
      if State.dead then
	 Direction = null
	 Position = null
	 ID = null
	 State
      else
	 case State.mode of seek then
	    RetVal = {NewPos}
	    case RetVal of RetPos#RetDir then
	       case RetDir of surface then NewState = {UpdateState State [pos#RetPos visited#(nil)]}
	       else
		  NewState = {UpdateState State [pos#RetPos visited#(RetPos|State.visited)]}
	       end
	       ID = NewState.id
	       Position = NewState.pos
	       Direction = RetDir
	       NewState
	    else State
	    end
	 [] destroy then
	    RetVal = {FollowPos firstCall}
	    case RetVal of RetPos#RetDir then
	       case RetDir of surface then NewState = {UpdateState State [pos#RetPos visited#(nil)]}
	       else
		  NewState = {UpdateState State [pos#RetPos visited#(RetPos|State.visited)]}
	       end
	       ID = NewState.id
	       Position = NewState.pos
	       Direction = RetDir
	       NewState
	    else State
	    end
	 else
	    State
	 end
      end
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun{Dive State} NewState in
      NewState = {UpdateState State [surf#false]}
      NewState
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun{ChargeItem State ID KindItem} NewState in
      if State.dead then
	 ID = null
	 KindItem = null
	 State
      else
	 case State.mode of seek then
	    NewState = {UpdateState State [sonarCharge#State.sonarCharge+1]}
	    ID = NewState.id
	    if (NewState.sonarCharge mod Input.sonar == 0) then
		  KindItem = sonar
	    else
	       KindItem = null
	    end
	 [] destroy then
	    NewState = {UpdateState State [missileCharge#State.missileCharge+1]}
	    ID = NewState.id
	    if (NewState.missileCharge mod Input.missile == 0) then
	       KindItem = missile
	    else
	       KindItem = null
	    end
	 else
	    NewState = State
	    ID = NewState.id
	    KindItem = null
	 end
	 NewState
      end
   end

   fun{FireItem State ID KindFire}
      fun{DistTo Pos1 Pos2}
	 {Number.abs Pos1.x-Pos2.x} + {Number.abs Pos1.y-Pos2.y}
      end
      NewState
   in
      if State.dead then
	 KindFire = null
	 State
      else
	 case State.mode of seek then
	    if State.sonarCharge >= Input.sonar then
	       KindFire = sonar
	       NewState = {UpdateState State [sonarCharge#(State.sonarCharge - Input.sonar)]}
	    else
	       KindFire = null
	       NewState = State
	    end
	 [] destroy then
	    if  State.missileCharge >= Input.missile andthen
	       {DistTo State.pos State.enemies.(State.target).pos} =< Input.maxDistanceMissile andthen
	       {DistTo State.pos State.enemies.(State.target).pos} >= Input.minDistanceMissile then
	       {System.show fire(State.id.id State.focus)}
	       KindFire = missile(State.enemies.(State.target).pos)
	       NewState = {UpdateState State [missileCharge#(State.missileCharge - Input.missile)]}
	    else
	       KindFire = null
	       NewState = State
	    end
	    ID = NewState.id
	    NewState	    
	 else
	    KindFire = null
	    NewState = State
	 end
      end
   end

   fun{FireMine State ID Mine}
      if State.dead then
	 Mine = null
	 ID = null
	 State
      else
	 ID = State.id
	 Mine = null
	 State
      end
   end

   fun{IsSurface State ID Answer}
      ID = State.id
      Answer = State.surf
      State
   end

   fun{SayMove State ID Direction} N StateN StateEn NewState in
            N = ID.id
      if State.enemies.N.spotted then
	 case Direction
	 of north then
	    StateN = {UpdateState State.enemies.N [pos#pt(x:State.enemies.N.pos.x-1 y:State.enemies.N.pos.y)]}
	    StateEn = {UpdateState State.enemies [N#StateN]}
	    NewState = {UpdateState State [enemies#StateEn]}
	 [] south then
	    StateN = {UpdateState State.enemies.N [pos#pt(x:State.enemies.N.pos.x+1 y:State.enemies.N.pos.y)]}
	    StateEn = {UpdateState State.enemies [N#StateN]}
	    NewState = {UpdateState State [enemies#StateEn]}
	 [] west then
	    StateN = {UpdateState State.enemies.N [pos#pt(x:State.enemies.N.pos.x y:State.enemies.N.pos.y-1)]}
	    StateEn = {UpdateState State.enemies [N#StateN]}
	    NewState = {UpdateState State [enemies#StateEn]}
	 [] east then
	    StateN = {UpdateState State.enemies.N [pos#pt(x:State.enemies.N.pos.x y:State.enemies.N.pos.y+1)]}
	    StateEn = {UpdateState State.enemies [N#StateN]}
	    NewState = {UpdateState State [enemies#StateEn]}
	 end
      else
	 NewState = State
      end
      NewState
   end

   fun{SaySurface State ID}
      State
   end

   fun{SayCharge State ID KindItem}
      State
   end

   fun{SayMinePlaced State ID}
      State
   end

   fun{SayMissileExplode State ID Position Message}
      fun{DistToSub State Pos}
	 {Number.abs State.pos.x - Pos.x} + {Number.abs State.pos.y - Pos.y}
      end
      NewState
      MidState
      Dist
   in
      Dist = {DistToSub State Position}
      if Dist == 0 then
	 MidState = {UpdateState State [hp#(State.hp-2)]}
      elseif Dist == 1 then
	 MidState = {UpdateState State [hp#(State.hp-1)]}
      else
	 MidState = State
	 NewState = State
      end
      if State.hp \= MidState.hp then
	 if MidState.hp =< 0 then
	    Message = sayDeath(State.id)
	    NewState = {UpdateState MidState [dead#true hp#0]}
	 else
	    Message = sayDamageTaken(State.id State.hp-MidState.hp MidState.hp)
	    NewState = MidState
	 end
      else
	 Message = null
      end
      NewState
   end

   fun{SayMineExplode State ID Position Message}
      fun{DistToSub State Pos}
	 {Number.abs State.pos.x - Pos.x} + {Number.abs State.pos.y - Pos.y}
      end
      NewState
      MidState
      Dist
   in
      Dist = {DistToSub State Position}
      if Dist == 0 then
	 MidState = {UpdateState State [hp#(State.hp-2)]}
      elseif Dist == 1 then
	 MidState = {UpdateState State [hp#(State.hp-1)]}
      else
	 MidState = State
	 NewState = State
      end
      if State.hp \= MidState.hp then
	 if MidState.hp =< 0 then
	    Message = sayDeath(State.ID)
	    NewState = {UpdateState MidState [dead#true hp#0]}
	 else
	    Message = sayDamageTaken(State.ID State.hp-MidState.hp MidState.hp)
	    NewState = MidState
	 end
      else
	 Message = null
      end
      NewState
   end

   fun{SayPassingDrone State Drone ID Answer}
      if State.dead then
	 Answer = null
	 ID = null
	 State
      else
	 case Drone
	 of drone(row X) then
	    if State.pos.x == X then
	       Answer = true
	    else
	       Answer = false
	    end
	 [] drone(column Y) then
	    if State.pos.y == Y then
	       Answer = true
	    else
	       Answer = false
	    end
	 end
	 ID = State.id
	 State
      end
   end

   fun{SayAnswerDrone State Drone ID Answer}
      State
   end

   fun{SayPassingSonar State ID Answer}
      if State.dead then
	 Answer = null
	 ID = null
	 State
      else
	 ID = State.id
	 Answer = pos(x:State.pos.x y:1)
	 State
      end
   end

   fun{SayAnswerSonar State ID Answer} NewState StateN StateEn in
      if (ID \= State.id andthen ID \= null) then
	 case State.mode of seek then
	    StateN = {UpdateState State.enemies.(ID.id) [pos#Answer spotted#true]}
	    StateEn = {UpdateState State.enemies [ID.id#StateN]}
	    NewState = {UpdateState State [focus#ID.id enemies#StateEn mode#destroy target#ID.id]}
	    NewState
	 [] destroy then
	    NewState = State
	 else NewState = State
	 end	 
      else
	 State
      end

   end

   fun{SayDeath State ID}
      case ID of null then
	 State
      [] Rec then
	 if State.target == Rec.id then
	    {UpdateState State [target#null mode#seek]}
	 else
	    State
	 end
      end
   end

   fun{SayDamageTaken State ID Damage LifeLeft}
      State
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{StartPlayer Color ID}
      Stream
      Port
      State
   in
      Port = {NewPort Stream}
      thread
	 State = {InitState ID Color} 
	 {TreatStream Stream State}
      end
      Port
   end
   
   proc{TreatStream Stream State}
      case Stream
      of nil then skip
      []initPosition(ID Position)|S then NewState in
	 NewState = {InitPosition State ID Position}
	 {TreatStream S NewState}
      []move(ID Position Direction)|S then NewState in
	 NewState = {Move State ID Position Direction}
	 {TreatStream S NewState}
      []dive|S then NewState in
	 NewState = {Dive State}
	 {TreatStream S NewState}
      []chargeItem(ID KindItem)|S then NewState in
	 NewState = {ChargeItem State ID KindItem}
	 {TreatStream S NewState}
      []fireItem(ID KindFire)|S then NewState in
	 NewState = {FireItem State ID KindFire}
	 {TreatStream S NewState}
      []fireMine(ID Mine)|S then NewState in
	 NewState = {FireMine State ID Mine}
	 {TreatStream S NewState}
      []isSurface(ID Answer)|S then NewState in
	 NewState = {IsSurface State ID Answer}
	 {TreatStream S NewState}
      []sayMove(ID Direction)|S then NewState in
	 NewState = {SayMove State ID Direction}
	 {TreatStream S NewState}
      []saySurface(ID)|S then NewState in
	 NewState = {SaySurface State ID}
	 {TreatStream S NewState}
      []sayCharge(ID KindItem)|S then NewState in
	 NewState = {SayCharge State ID KindItem}
	 {TreatStream S NewState}
      []sayMinePlaced(ID)|S then NewState in
	 NewState = {SayMinePlaced State ID}
	 {TreatStream S NewState}
      []sayMissileExplode(ID Position Message)|S then NewState in
	 NewState = {SayMissileExplode State ID Position Message}
	 {TreatStream S NewState}
      []sayMineExplode(ID Position Message)|S then NewState in
	 NewState = {SayMineExplode State ID Position Message}
	 {TreatStream S NewState}
      []sayPassingDrone(Drone ID Answer)|S then NewState in
	 NewState = {SayPassingDrone State Drone ID Answer}
	 {TreatStream S NewState}
      []sayAnswerDrone(Drone ID Answer)|S then NewState in
	 NewState = {SayAnswerDrone State Drone ID Answer}
	 {TreatStream S NewState}
      []sayPassingSonar(ID Answer)|S then NewState in
	 NewState = {SayPassingSonar State ID Answer}
	 {TreatStream S NewState}
      []sayAnswerSonar(ID Answer)|S then NewState in
	 NewState = {SayAnswerSonar State ID Answer}
	 {TreatStream S NewState}
      []sayDeath(ID)|S then NewState in
	 NewState = {SayDeath State ID}
	 {TreatStream S NewState}
      []sayDamageTaken(ID Damage LifeLeft)|S then NewState in
	 NewState = {SayDamageTaken State ID Damage LifeLeft}
	 {TreatStream S NewState}
      else
	 skip
      end
   end 
end
