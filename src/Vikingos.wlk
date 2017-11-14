class Vikingo {

	var casta = jarl 
	var dinero = 0

	method puedeSubirA(expedicion)
		= self.esProductivo() and casta.puedeIr(self,expedicion)

	method esProductivo()

	method aumentarVidasCobradas(){} //no hace nada

	// punto entrada punto 5
	method ascender(){ 
		casta.ascender(self)
	}
	method cambiarCasta(cas){
		casta = cas
	}
	method agregarAlBotinPersonal(cantOro){
		dinero += cantOro
	}
	method dinero() = dinero
}

class Soldado inherits Vikingo{

	var vidasCobradas 
	var cantArmas

	constructor(vidas,_cantArmas) {
		vidasCobradas = vidas
		cantArmas = _cantArmas
	}
	override method esProductivo() = vidasCobradas > 20 and self.tieneArmas()

	method tieneArmas() = cantArmas > 0

	override method aumentarVidasCobradas(){
		vidasCobradas += 1
	}
	
	method bonificarAscenso(){
		cantArmas += 10
	}
	
	method vidasCobradas() = vidasCobradas

}

class Granjero inherits Vikingo {

	var cantHijos
	var cantHectareas

	constructor(_cantHijos,_cantHectareas) {
		cantHijos = _cantHijos
		cantHectareas = _cantHectareas 
	}
	override method esProductivo() =
		 cantHectareas * 2 >= cantHijos 

	method tieneArmas() = false

	method bonificarAscenso(){
		cantHijos += 2
		cantHectareas += 2
	}
}

class Expedicion {
	const integrantes = []
	var objetivos
	
	constructor(lugares){objetivos = lugares}

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
			int.agregarAlBotinPersonal(botin / self.cantidadIntegrantes())
		}
	}
	method aumentarVidasCobradasEn(lugar) { 
		self.asesinosEn(lugar).forEach{int => 
			int.aumentarVidasCobradas()
		}
	}
	method asesinosEn(lugar) = integrantes.take(lugar.defensoresDerrotados(self.cantidadIntegrantes()))
	method integrantes() = integrantes
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
	var cantCrucifijos

	constructor(_cantCrucifijos){
		cantCrucifijos = _cantCrucifijos
	}
	method valeLaPenaPara(cantInvasores) = self.botin(cantInvasores) >= 15

	override method botin(cantInvasores) = cantCrucifijos

	override method destruirse(cantInvasores){
		cantCrucifijos = 0
	}
	
	method cantCrucifijos() = cantCrucifijos
}

class AldeaAmurallada inherits Aldea {
	var minimosVikingos
	constructor(_cantCrucifijos, vikingos) = super(_cantCrucifijos){
		minimosVikingos = vikingos
	}
	override method valeLaPenaPara(cantInvasores) 
		= cantInvasores >= minimosVikingos and super(cantInvasores)
}

class Capital inherits Lugar{
	var cantDefensores 
	var factorDeRiqueza

	constructor(_cantDefensores,riqueza){
		cantDefensores = _cantDefensores
		factorDeRiqueza = riqueza
	}
	method valeLaPenaPara(cantInvasores) =
		cantInvasores <= self.botin(cantInvasores) / 3

	override method botin(cantInvasores) =
		 self.defensoresDerrotados(cantInvasores) * factorDeRiqueza
	
	override method destruirse(cantInvasores){
		cantDefensores -= self.defensoresDerrotados(cantInvasores)
	}
	override method serInvadidoPor(expedicion){
		expedicion.aumentarVidasCobradasEn(self)
		super(expedicion)
	}
	method defensoresDerrotados(cantInvasores) = cantDefensores.min(cantInvasores)
	method cantDefensores() = cantDefensores
	method cantDefensores(_cant){cantDefensores=_cant}

}



class Casta {
	method puedeIr(vikingo,expedicion) = true
}

object jarl inherits Casta {
	
	override method puedeIr(vikingo, expedicion) = not vikingo.tieneArmas()

	method ascender(vikingo){
		vikingo.cambiarCasta(karl)
		vikingo.bonificarAscenso()
	}
}
object karl inherits Casta{
	method ascender(vikingo){
		vikingo.cambiarCasta(thrall)
	}
}

object thrall inherits Casta{
	method ascender(vikingo){
		// no hace naranja
	}
}

object noPuedeSubirAExpedicion inherits Exception {}



// Para agregar un nuevo objetivo castillo, este debe ser polimórfico con los otros objetivos existentes. No hace falta modificar código existente, siempre y cuando se implementen los mensajes valeLaPenaPara, botin, y serInvadidoPor (y siempre y cuando no necesite más cosas del vikingo para resolver esos métodos, en cuyo caso convendría pasar el vikingo por parámetro)
