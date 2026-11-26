# Referentes

Busca en la App Store "light meter" y "exposímetro", y apps de cámara manual. Elige 4 o 5. Por cada una llena una fila.

| App | Qué hace bien | Qué evitar | Captura (ruta en Design/refs/) |
|---|---|---|---|
| Light meter | Casi nada | Simula la forma y apariencia en pantalla de un exposimetro real aunque realmente parece nada mas una imagen fija, la medicion la realiza con la camara frontal y es poco intuitiva se ve que tiene mucho tiempo sin actualizarse y constantemente envia una alerta sobre que hay que usar un difusor pero la alerta no se puede quitar. | Design/refs/IMG_2723.PNG |
| LUMU Light Meter | Spot metering pero es la unica funcion que tiene | La pantalla principal es como un menu en donde solo dice spot metering, pareciera que no la actualizaron con las funciones restantes y que tiene bastante tiempo asi, al dar tap en spot metering manda a otra pantalla donde se aprecia la camara en un recuadro y en la parte inferior los valores tiempo, velocidad de obturacion e ISO pero no se ajustan automaticamente, tienes que mantener el telefono apuntando al objetivo hacer tap en el recuadro de la camara para realizar la medicion puntual (ahi realiza un zoom horrible al punto) y despues te indica en la parte superior con una etiqueta si la escena esta subexpuesta o sobreexpuesta, entonces puedes mover los valores de la parte inferior para encontrar la exposicion correcta | Design/refs/IMG_2724.PNG Design/refs/IMG_2725.PNG |
| Lghtmtr | La interfaz es bonita, usa mucho blur en varios lados y tiene una opcion para crear perfiles de camara que tengas | Su funcion es mas bien guardar perfiles de camara y en base al perfil guardes mediciones, las mediciones de luz no las hace en tiempo real sino que debes tomar una foto de la escena y en base a eso te presenta una tabla donde puede ver los valores y ajustarlos si deseas, tambien puedes bloquearlos para guardarlos | Design/refs/IMG_2726.PNG Design/refs/IMG_2727.PNG |
| | | | |

## Preguntas para decidir con los referentes

1. ¿La vista previa de la cámara va a pantalla completa o en un recuadro?
    En la mayoria de los ejemplos que descargue la camara se muestra en un recuadro y muestra en los bordes los botones de las acciones, creo que en nuestro caso en nuestra app podemos intentar que este en pantalla completa, los botones sobre la camara usando liquid glass para un mejor efecto visual
2. ¿Qué dato es el protagonista: el EV o la exposición sugerida (apertura, velocidad, ISO)?
    En la mayoria es la exposicion sugerida, creo que en nuestra app tambien deberamos darle foco a los valores sugeridos pero debemos encontrar la forma en que sea facil de leer, creo que la medicion tambien deberia ser en tiempo real con un debounce para no cambiar los valores demasiado rapido o tal vez con algun boton de "tomar medicion" o algo por el estilo, tal vez si tomamos en cuenta el funcionamiento de un exposimetro real podamos llevarlo a la app
3. ¿Cómo se ven los controles con una sola mano?
    A una mano es dificil saber que es lo que se tiene que hacer en las apps de ejemplo que baje, son poco intuitivas y es dificil saber todas las funciones que tienen.
4. ¿Qué tan técnico es el lenguaje de la interfaz?
    Creo que son bastante tecnicas suponiendo que su publico objetivo generalmente son creativos como fotografos en la mayoria encontre referencias a ISO, velocidad y apertura en la app Lumu Light Meter en la parte de la camara incluso vemos los valores sin etiquetas, alguien que no es fotografo no sabria a que se refieren esos valores
5. ¿Qué detalle visual se queda en la memoria?
    En mi opinion que las apps son bastante feas y poco intuitivas para el usuario, son dificles de usar y no dan ganas de quedarse ahi por mucho tiempo para intentar descubrir como funcionan en realidad

