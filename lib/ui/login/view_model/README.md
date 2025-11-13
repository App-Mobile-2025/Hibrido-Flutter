# ViewModel de la feature

Esta carpeta contiene la lógica de presentación específica de esta pantalla o módulo.  
Aquí se gestionan los estados, validaciones y llamadas a los repositorios o servicios necesarios para que la UI funcione.

Cada clase ViewModel debe:
- Extender `ChangeNotifier` (u otro gestor de estado que se utilice).
- Exponer las variables reactivas que la UI consumirá.
- Incluir los métodos para manejar interacciones del usuario (por ejemplo: login, cargar datos, enviar formulario, etc.).
