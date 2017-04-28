functor
import
   Player98Dumb
   Player98SeekDestroy
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
      case Kind
      of nil then nil
      [] seekDestroy then
	 {Player98SeekDestroy.portPlayer Color ID}
      [] dumb then
	 {Player98Dumb.portPlayer Color ID}
      else
	 nil
      end
   end
end

	 