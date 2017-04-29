functor
import
   Input
   OS %rand
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream

   InitState
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

   Items
   RandomItem
   RandomEnemy

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
		    id:id(id:ID color:Color name:'Dummy')
		    dead:false
		    hp:Input.maxDamage
		    missileCharge:0
		    mineCharge:0
		    sonarCharge:0
		    droneCharge:0
		    enemies:data(1:null)
		    surf:true
		    visited:nil
		    focus:null
		    mode:seek
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
      RetVal
   in
      if State.dead then
	 Direction = null
	 Position = null
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

   Items = [mine missile sonar drone]

   fun{RandomItem}
      {Nth Items (({OS.rand} mod {Length Items}) + 1)}
   end
   
   fun{ChargeItem State ID KindItem}
      NewState
      Item
   in
      if State.dead then
	 KindItem = null
	 State
      else
	 Item = {RandomItem}
	 case Item of missile then
	    NewState = {UpdateState State [missileCharge#State.missileCharge+1]}
	    ID = NewState.id
	    if NewState.missileCharge mod Input.missile == 0 then
	       KindItem = missile
	    else
	       KindItem = null
	    end
	 [] sonar then
	    NewState = {UpdateState State [sonarCharge#State.sonarCharge+1]}
	    ID = NewState.id
	    if NewState.sonarCharge mod Input.sonar == 0 then
	       KindItem = sonar
	    else
	       KindItem = null
	    end
	 [] drone then
	    NewState = {UpdateState State [droneCharge#State.droneCharge+1]}
	    ID = NewState.id
	    if NewState.droneCharge mod Input.drone == 0 then
	       KindItem = drone
	    else
	       KindItem = null
	    end
	 [] mine then
	    NewState = {UpdateState State [mineCharge#State.mineCharge+1]}
	    ID = NewState.id
	    if NewState.mineCharge mod Input.mine == 0 then
	       KindItem = mine
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

   fun{RandomEnemy}
      (({OS.rand} mod Input.nbPlayer) + 1)
   end
   
   fun{FireItem State ID KindFire}
      fun{DistTo Pos1 Pos2}
	 {Number.abs Pos1.x-Pos2.x} + {Number.abs Pos1.y-Pos2.y}
      end
      NewState
      Item
      N
   in
      if State.dead then
	 KindFire = null
	 State
      else
	 Item = {RandomItem}
	 N = {RandomEnemy}
	 case Item of sonar then
	    if State.sonarCharge >= Input.sonar then
	       %FIRE SONAR
	       KindFire = sonar
	       NewState = {UpdateState State [sonarCharge#(State.sonarCharge - Input.sonar)]}
	    else
	       KindFire = null
	       NewState = State
	    end
	 [] missile then
	    if State.enemies.N.spotted andthen State.missileCharge >= Input.missile andthen
	       {DistTo State.pos State.enemies.N.pos} =< Input.maxDistanceMissile andthen
	       {DistTo State.pos State.enemies.N.pos} >= Input.minDistanceMissile then
	       KindFire = missile(State.enemies.N.pos)
	       NewState = {UpdateState State [missileCharge#(State.missileCharge - Input.missile)]}
	    else
	       KindFire = null
	       NewState = State
	    end
	 else
	    KindFire = null
	    NewState = State
	 end
	 ID = NewState.id
	 NewState
      end
   end


   fun{FireMine State ID Mine}
      ID = State.id
      Mine = null
      State
   end

   fun{IsSurface State ID Answer}
      ID = State.id
      Answer = State.surf
      State
   end

   fun{SayMove State ID Direction}
      State
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

   fun{SayAnswerDrone State Drone ID Answer}
      State
   end

   fun{SayPassingSonar State ID Answer}
      ID = State.id
      Answer = State.pos
      State
   end

   fun{SayAnswerSonar State ID Answer} StateN StateEn NewState in
      if (ID \= State.id andthen ID \= null) then
	 StateN = {UpdateState State.enemies.(ID.id) [pos#Answer spotted#true]}
	 StateEn = {UpdateState State.enemies [ID.id#StateN]}
	 NewState = {UpdateState State [focus#ID.id enemies#StateEn]}
	 NewState
      else
	 State
      end
   end

   fun{SayDeath State ID}
      State
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
