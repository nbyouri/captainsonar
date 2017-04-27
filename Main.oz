functor
import
   GUI
   Input
   System
   PlayerManager
define
   Port
   PlayerPort
   NewPlayer
   LoadPlayer
   NewTurn

   StartTurnByTurn
   StartSimultaneous
   SubAction

   InitState
   UpdateState

   BroadCast
   BroadCastMessage

   IsAlive
   StartSimultaneous
   LaunchSubmarine
in
%%%%%%%%%%%Create Player %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   Port = {GUI.portWindow}
   {Send Port buildWindow}
   fun {NewPlayer Count}
      if Count > Input.nbPlayer then nil
      else
	 {PlayerManager.playerGenerator {List.nth Input.players Count} {List.nth Input.colors Count} Count} | {NewPlayer Count+1}
      end
   end

   proc {LoadPlayer PlayerPort}
      ID
      Pos
   in
      case PlayerPort of nil then skip
	 [] H|T then
	 {Send H initPosition(ID Pos)}
	 {Send Port initPlayer(ID Pos)}
	 {LoadPlayer T}
      end
   end

   fun{InitState State}
      fun{Loop State N}
	 if N == 0 then
	    State
	 else SubState in
	    SubState = {UpdateState State [N#player(id:N pos:0 surf:0)]}
	    {Loop SubState N-1}
	 end
      end
   in
      {Loop State Input.nbPlayer}
   end

   fun{UpdateState State L}
      {AdjoinList State L}
   end

%%%%%%%%%%%%%%%%Start Game %%%%%%%%%%%%%%%%%%%%%%%%%%
   PlayerPort = {NewPlayer 1}
   {LoadPlayer PlayerPort}

   proc{StartTurnByTurn}
      {NewTurn {InitState state()} PlayerPort PlayerPort true}
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   proc{BroadCastMessage Message ID Submarine}
      Ans
      IDAns
   in
      case Message of surface then
	 {Send Submarine saySurface(ID)}
      [] east then
	 {Send Submarine sayMove(ID east)}
      [] west then
	 {Send Submarine sayMove(ID west)}
      [] north then
	 {Send Submarine sayove(ID north)}
      [] south then
	 {Send Submarine sayMove(ID south)}
      [] KindItem#charge then
	 {Send Submarine sayCharge(ID KindItem)}
      [] mine(Pos)#place then
	 {Send Submarine sayMinePlaced(ID)}
	 {Send Port putMine(ID Pos)}
      [] mine(Pos)#explode then
	 {Send Submarine sayMineExplode(ID Pos Ans)}
	 {Send Port removeMine(ID Pos)}
	 case Ans of null then skip
	 [] sayDeath(DamageID) then
	    {Send Port removePlayer(DamageID)}
	    {BroadCast Ans Ans.1 PlayerPort} %Broadcast damage
	 [] sayDamageTaken(DamageID _ LifeLeft) then
	    {Send Port lifeUpdate(DamageID LifeLeft)}
	    {BroadCast Ans Ans.1 PlayerPort}
	 else skip 
	 end
      [] missile(Pos) then
	 {Send Submarine sayMissileExplode(ID Pos Ans)}
	 case Ans of null then skip
	 [] sayDeath(DamageID) then
	    {Send Port removePlayer(DamageID)}
	    {BroadCast Ans Ans.1 PlayerPort}
	 [] sayDamageTaken(DamageID _ LifeLeft) then
	    {Send Port lifeUpdate(DamageID LifeLeft)}
	    {BroadCast Ans Ans.1 PlayerPort}
	 else skip
	 end
      [] drone(_) then
	 {Send Submarine sayPassingDrone(Message IDAns Ans)}
	 case IDAns of null then skip
	 else{BroadCast Ans#drone IDAns PlayerPort} %Broadcast drone Ans
	 end
      [] sonar then
	 {Send Submarine sayPassingSonar(IDAns Ans)}
	 case IDAns of null then skip
	 else {BroadCast Ans#sonar IDAns PlayerPort} %BroadCast sonar Ans
	 end
      [] Ans#drone then
	 {Send Submarine sayAnswerDrone(ID Ans)}
      [] Ans#sonar then
	 {Send Submarine sayAnswerSonar(ID Ans)}
      [] sayDeath(DamageID) then
	 {Send Submarine sayDeath(DamageID)}
      [] sayDamageTaken(DamageID Damage LifeLeft) then
	 {Send Submarine sayDamageTaken(DamageID Damage LifeLeft)}
      else
	 skip
      end
   end
   
   proc{BroadCast Message ID Submarines}
      case Submarines of nil then skip
      [] H|T then
	 {BroadCastMessage Message ID H} %BroadCast the Message to sub
	 {BroadCast Message ID T} %Recursive Call	 
      end
   end

   proc{SubAction State NewState Submarine FirstTurn}
      IsSurf
      ID
      Direction
      Position
      SubState
      NewSurfTime
      Leave
      KindItem
      KindFire
      Mine
   in
      {Send Submarine isSurface(ID IsSurf)} %Ask if Submarine is Surface
      %%%%%%%%%% MOVING %%%%%%%%%%%%%
      if (State.(ID.id).surf > 0) then
	 NewSurfTime = State.(ID.id).surf - 1
	 SubState = {UpdateState State.(ID.id) [surf#NewSurfTime]}
	 NewState = {UpdateState State [ID.id#SubState]}
	 Leave = yes
      elseif (IsSurf orelse FirstTurn) then
	 {Send Submarine dive}
	 Leave = no
      else Leave = no
      end
      case Leave of yes then skip
      [] _ then
	 {Send Submarine move(ID Position Direction)} %Ask for direction
	 case Direction of surface then
	    {Send Port surface(ID)}
	    SubState = {UpdateState State.(ID.id) [surf#Input.turnSurface]}
	    NewState = {UpdateState State [ID.id#SubState]}
	 else
	    {Send Port movePlayer(ID Position)}
	    SubState = {UpdateState State.(ID.id) [pos#Position]}
	    NewState = {UpdateState State [(ID.id)#SubState]}
	 end
	 {BroadCast Direction ID PlayerPort}
         %%%%%%%%%%% ITEM %%%%%%%%%%%%%
	 {Send Submarine chargeItem(ID KindItem)} %Ask for charge
	 case KindItem of null then skip
	 [] _ then {BroadCast KindItem#charge ID PlayerPort} %BroadCast Charge
	 else skip
	 end
         %%%%%%%%%%% FIRE %%%%%%%%%%%%%
	 {Send Submarine fireItem(ID KindFire)}
	 case KindFire of null then skip
	 [] mine(_) then
	    {BroadCast KindFire#place ID PlayerPort} %broadcast mine placed
	    %Check if the sub is hit by the explosien maybe ?
	 [] missile(_) then
	    {BroadCast KindFire ID PlayerPort}
	    %Check if the sub is hit by the explosion
	 [] drone(_) then
	    {BroadCast KindFire ID PlayerPort}
	    %Broadcast the drone
	 [] sonar then
	    {BroadCast KindFire ID PlayerPort}
	    %Broadcast the sonar
	 else
	    skip
	 end
	 if {IsAlive Submarine} then
	    {Send Submarine fireMine(ID Mine)}%Ask for mine explosion
	    case Mine of null then skip
	    [] _ then
	       {BroadCast KindFire#explode ID PlayerPort}
	    else skip
	    end
	 end
      end
   end

   fun{IsAlive Sub} ID in
      {Send Sub isSurface(ID _)}
      case ID of null then
	 false
      else true
      end
   end
   
   proc{NewTurn State PlayerPort Data FirstTurn}
      NTState
   in
      %{Delay 200}
      %Add victory condition to exit loop
      case Data of nil then {NewTurn State PlayerPort PlayerPort false}
      [] Submarine|ST then
	 if {IsAlive Submarine} then
	    {SubAction State NTState Submarine FirstTurn}
	 else
	    NTState = State
	 end
	 {NewTurn NTState PlayerPort ST FirstTurn}
      end
   end
%%%%%%%%Simultaneous%%%%%%%%%%
   %%%%%%%%%%%%%%%%Simultaneous game %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   proc{LaunchSubmarine Submarine Beginning}
      MoveID
      KindID
      FireID
      MineID
      NullID
      Direction
      Position
      KindItem
      KindFire
      Mine
      Ans
   in
      case Beginning of yes then {Send Submarine dive}
      [] no then skip
      end
      {Delay Input.thinkMin}
      {Send Submarine move(MoveID Position Direction)}
      case Direction of surface then
	 {Send Port surface(MoveID)}
	 {Delay Input.turnSurface * 1000}
      else skip
      end
      {Send Port movePlayer(MoveID Position)}
      {BroadCast Direction MoveID PlayerPort}

      {Delay Input.thinkMin}
%%%%%%%%%% ITEM %%%%%%%%

      	 {Send Submarine chargeItem(KindID KindItem)} %Ask for charge
	 case KindItem of null then skip
	 [] H then {BroadCast KindItem#charge KindID PlayerPort} %BroadCast Charge
	 else skip
	 end
	 {Delay Input.thinkMin}
      %%%%%%%%%%%% Fire %%%%%%
	 {Send Submarine fireItem(FireID KindFire)} %Ask for fire item
	 case KindFire of null then skip
	 [] mine(Pos) then
	    {BroadCast KindFire#place FireID PlayerPort} %broadcast mine placed
	    %Check if the sub is hit by the explosien maybe ?
	 [] missile(Pos) then
	    {BroadCast KindFire FireID PlayerPort}
	    %Check if the sub is hit by the explosion
	 [] drone(H) then
	    {BroadCast KindFire FireID PlayerPort}
	    %Broadcast the drone
	 [] sonar then
	    {BroadCast KindFire FireID PlayerPort}
	    %Broadcast the sonar
	 else skip
	 end
	 {Delay Input.thinkMin}
%%%%%%%%%%% MINE %%%%%%%%
	 {Send Submarine fireMine(MineID Mine)}%Ask for mine explosion
	 case Mine of nil then skip
	 [] H then
	    {BroadCast KindFire#explode MineID PlayerPort}
	 end
	 {Send Submarine isSurface(NullID Ans)}
	 case NullID of null then skip
	 else
	    {LaunchSubmarine Submarine no}
	 end
   end
   
   proc{StartSimultaneous}
      LaunchGame
   in
      proc{LaunchGame Submarines PlayerPort}
	 case Submarines of nil then skip
	 [] H|T then
	    thread {LaunchSubmarine H yes} end
	    {LaunchGame T PlayerPort}
	 end
      end
      {LaunchGame PlayerPort PlayerPort}
   end


%%%%%%%%%%%%%%%%%%%%%
   if (Input.isTurnByTurn) then
      {StartTurnByTurn}
   else
      {StartSimultaneous}
   end
end