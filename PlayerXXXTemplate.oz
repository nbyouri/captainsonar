functor
import
   Input
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream
in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Update un State avec une liste de tuple contenant les valeurs qui ont changé
   % state(a:1 b:2) + [b#3] = state(a:1 b:3)
   fun{UpdateState State L}
      {AdjoinList State L}
   end

   fun{InitPosition State ID Position}
      %
   end

   fun{Move State ID Position Direction}
      %
   end

   fun{Dive State}
      %
   end

   fun{ChargeItem State ID KindItem}
      %
   end

   fun{FireItem State ID KindFire}
      %
   end

   fun{FireMine State ID Mine}
      %
   end

   fun{IsSurface State ID Answer}
      %
   end

   fun{SayMove State ID Direction}
      %
   end

   fun{SaySurface State ID}
      %
   end

   fun{SayCharge State ID KindItem}
      %
   end

   fun{SayMinePlaced State ID}
      %
   end

   fun{SayMissileExplode State ID Position Message}
      %
   end

   fun{SayMineExplode State ID Position Message}
      %
   end

   fun{SayPassingDrone State Drone ID Answer}
      %
   end

   fun{SayAnswerDrone State Drone ID Answer}
      %
   end

   fun{SayPassingSonar State ID Answer}
      %
   end

   fun{SayAnswerSonar State ID Answer}
      %
   end

   fun{SayDeath State ID}
      %
   end

   fun{SayDamageTaken State ID Damage LifeLeft}
      %
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{StartPlayer Color ID}
      Stream
      Port
   in
      Port = {NewPort Stream}
      thread
	 {TreatStream Stream State}
      end
      Port
   end
   
   proc{TreatStream Stream State}
      %Le State va être les infos sur notre Sub, ou autre chose
      %Pv, position, munitions, ...
      %state(id:ID pos:POS  ...)
      
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
