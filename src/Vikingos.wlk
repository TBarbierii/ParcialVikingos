class Vikingo {

	var property casta = jarl 
	var property oro = 0

	method puedeSubirA(expedicion)
		= self.esProductivo() and casta.puedeIr(self,expedicion)

	method esProductivo()

	method cobrarVida(){} //no hace nada

	// punto entrada punto 5
	method ascender(){ 
		casta.ascender(self)
	}
	
	method ganar(monedas){
		oro += monedas
	}
}

class Soldado inherits Vikingo{

	var property vidasCobradas 
	var armas

	override method esProductivo() = vidasCobradas > 20 and self.tieneArmas()

	method tieneArmas() = armas > 0

	override method cobrarVida(){
		vidasCobradas += 1
	}
	
	method bonificarAscenso(){
		armas += 10
	}
	
}

class Granjero inherits Vikingo {

	var hijos
	var hectareas

	override method esProductivo() =
		 hectareas * 2 >= hijos 

	method tieneArmas() = false

	method bonificarAscenso(){
		hijos += 2
		hectareas += 2
	}
}

class Expedicion {
	const property integrantes = []
	var objetivos 
	
	// punto de entrada del punto 1
	method subir(vikingo){ 
		if (not vikingo.puedeSubirA(self))
			throw noPuedeSubirAExpedicion
		integrantes.add(vikingo)
	}
	// punto de entrada del punto 2
	method valeLaPena() 
		= objetivos.all{obj => obj.valeLaPenaPara(self.cantidadIntegrantes())}

	// punto de entrada del punto 3
	method realizar() {  
		objetivos.forEach{obj => obj.serInvadidoPor(self)}
	}

	method repartirBotin(botin){
		integrantes.forEach{int => 
			int.ganar(botin / self.cantidadIntegrantes())
		}
	}
	method aumentarVidasCobradasEn(cantidad) { 
		integrantes.take(cantidad).forEach{int => 
			int.cobrarVida()
		}
	}
	
	method cantidadIntegrantes() = integrantes.size()
	method agregarLugar(objetivo){objetivos.add(objetivo)}
}

class Lugar {
	
	method serInvadidoPor(expedicion) {
		expedicion.repartirBotin(self.botin(expedicion.cantidadIntegrantes()))
		self.destruirse(expedicion.cantidadIntegrantes())

	}
	method destruirse(cantInvasores)
	method botin(cantInvasores)
}

class Aldea inherits Lugar{
	var property crucifijos

	method valeLaPenaPara(cantInvasores) = self.botin(cantInvasores) >= 15

	override method botin(cantInvasores) = crucifijos

	override method destruirse(cantInvasores){
		crucifijos = 0
	}
}

class AldeaAmurallada inherits Aldea {
	var minimosVikingos

	override method valeLaPenaPara(cantInvasores) 
		= cantInvasores >= minimosVikingos and super(cantInvasores)
}

class Capital inherits Lugar{
	var property defensores 
	var riqueza

	method valeLaPenaPara(cantInvasores) =
		cantInvasores <= self.botin(cantInvasores) / 3

	override method botin(cantInvasores) =
		 self.defensoresDerrotados(cantInvasores) * riqueza
	
	override method destruirse(cantInvasores){
		defensores -= self.defensoresDerrotados(cantInvasores)
	}
	override method serInvadidoPor(expedicion){
		expedicion.aumentarVidasCobradasEn(self.defensoresDerrotados(expedicion.cantidadIntegrantes()))
		super(expedicion)
	}
	method defensoresDerrotados(cantInvasores) = defensores.min(cantInvasores)

}



class Casta {
	method puedeIr(vikingo,expedicion) = true
}

object jarl inherits Casta {
	
	override method puedeIr(vikingo, expedicion) = not vikingo.tieneArmas()

	method ascender(vikingo){
		vikingo.casta(karl)
		vikingo.bonificarAscenso()
	}
}
object karl inherits Casta{
	method ascender(vikingo){
		vikingo.casta(thrall)
	}
}

object thrall inherits Casta{
	method ascender(vikingo){
		// no hace naranja
	}
}

object noPuedeSubirAExpedicion inherits Exception {}



// Para agregar un nuevo objetivo castillo, este debe ser polimórfico con los otros objetivos existentes. No hace falta modificar código existente, siempre y cuando se implementen los mensajes valeLaPenaPara, botin, y serInvadidoPor (y siempre y cuando no necesite más cosas del vikingo para resolver esos métodos, en cuyo caso convendría pasar el vikingo por parámetro)
