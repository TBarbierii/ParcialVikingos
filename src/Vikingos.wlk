class Vikingo {

	var casta = jarl 

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

}

class Soldado inherits Vikingo{

	var vidasCobradas 
	var cantArmas

	constructor(vidas,armas) {
		vidasCobradas = vidas
		cantArmas = armas
	}
	override method esProductivo() = vidasCobradas > 20 and self.tieneArmas()

	method tieneArmas() = cantArmas > 0

	override method aumentarVidasCobradas(){
		vidasCobradas += 1
	}
	
	method bonificarAscenso(){
		cantArmas += 10
	}

}

class Granjero inherits Vikingo {

	var hijos
	var hectareas

	constructor(cantHijos,cantHectareas) {
		hijos = cantHijos
		hectareas = cantHectareas 
	}
	override method esProductivo() =
		 hectareas * 2 >= hijos 

	method tieneArmas() = false

	method bonificarAscenso(){
		hijos += 2
		hectareas += 2
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
	method aumentarVidasCobradas() { 
		integrantes.forEach{int => 
			int.aumentarVidasCobradas()
		}
	}
	method integrantes() = integrantes
	method cantidadIntegrantes() = integrantes.size()
	method agregarLugar(objetivo){objetivos.add(objetivo)}
}

class Lugar {
	
	method serInvadidoPor(expedicion) {
		self.destruirse(expedicion.cantidadIntegrantes())
		expedicion.repartirBotin(self.botin(expedicion.cantidadIntegrantes()))
	}
	method destruirse(invasores)
	method botin(invasores)
}

class Aldea inherits Lugar{
	var crucifijos

	constructor(cantCrucifijos){
		crucifijos= cantCrucifijos
	}
	method valeLaPenaPara(invasores) = self.botin(invasores) >= 15

	override method botin(invasores) = crucifijos

	override method destruirse(invasores){
		crucifijos = 0
	}
}

class AldeaAmurallada inherits Aldea {
	var minimosVikingos
	constructor(crucifijos, vikingos) = super(crucifijos){
		minimosVikingos = vikingos
	}
	override method valeLaPenaPara(invasores) 
		= invasores >= minimosVikingos and super(invasores)
}

class Capital inherits Lugar{
	var defensores 
	var factorDeRiqueza

	constructor(cantDefensores,riqueza){
		defensores = cantDefensores
		factorDeRiqueza = riqueza
	}
	method valeLaPenaPara(invasores) =
		invasores <= self.botin(invasores) / 3

	override method botin(invasores) =
		 self.defensoresDerrotados(invasores) * factorDeRiqueza
	
	override method destruirse(invasores){
		defensores -= self.defensoresDerrotados(invasores)
	}
	override method serInvadidoPor(expedicion){
		super(expedicion)
		expedicion.aumentarVidasCobradas()
	}
	method defensoresDerrotados(invasores) = defensores.min(invasores)

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
