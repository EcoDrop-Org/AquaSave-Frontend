# Integración con el backend

Referencia de cómo esta app habla con `AquaSave-Backend`. Todo lo que aquí se
describe está **implementado y probado** en ambos lados (32 pruebas E2E).

Repos hermanos:

- Backend: `../../Backend/AquaSave-Backend` (rama `main`)
- EdgeAPI: `../../AquaSave-EdgeAPI` (rama `develop`)
- Firmware: `../../AquaSave-Device` (rama `develop`)

## Segmentos de usuario

`profileType` en `POST /api/auth/register` es uno de los dos segmentos del
informe (§1.3):

| Valor | Segmento |
|---|---|
| `principiante` | Necesita orientación para interpretar las lecturas |
| `experto` | Quiere historial, cifras y configuración |

La app adapta qué muestra según este valor (`context.userSegment`), y el
backend redacta las recomendaciones distinto para cada uno.

Las cuentas creadas antes del cambio guardan los valores geográficos
anteriores (`horticultor-urbano`, `micro-agricultor-periurbano`). El backend
los acepta y los mapea; `UserSegment.fromApi()` hace lo mismo en el front.

## Un dispositivo = una planta

Un dispositivo de riego atiende **una** planta: el sensor de humedad mide una
sola maceta, así que `plantCount` nunca representó la realidad. Está
deprecado y siempre vale 1.

Campos relevantes de `Device`:

| Campo | Para qué |
|---|---|
| `speciesId` | Especie; define los umbrales de humedad que deciden el riego |
| `cropType` | Nota libre del usuario (ya no transporta la especie) |
| `hasIrrigationDevice` | `false` si la planta existe pero aún no tiene dispositivo |

Una planta **puede existir sin dispositivo**: la app muestra su ficha y
cuidados, solo sin lecturas ni riego automático. Por eso el wizard pide
primero la especie y conecta el dispositivo después.

## Catálogo de especies ⚠️

`lib/features/devices/domain/entities/plant_species.dart` debe mantenerse
**idéntico** a `device-management/domain/plant-species.ts` del backend.

Si los umbrales divergen, la app mostraría un rango distinto al que el backend
usa para decidir el riego, y el usuario vería recomendaciones que no cuadran
con la ficha. Al agregar una especie, agregarla en los dos lados.

Es un catálogo estático porque ninguna API pública da estos umbrales de forma
confiable, y así no depende de la red.

## Recomendaciones

```http
GET /api/irrigation/devices/:deviceId/recommendation
Authorization: Bearer <token>
```

Devuelve tres cosas:

1. `irrigation` — si hay que regar (humedad del suelo + umbrales de la especie
   + clima). Se muestra en Inicio.
2. `care` — cuidados de la especie. **No dependen del sensor**, así que sirven
   sin dispositivo. Se muestran en el detalle de la planta.
3. `info` — descripción y foto de la especie. Opcional.

El campo `source` (`rules` | `ai`) dice quién redactó el texto. La app marca
con un badge lo que escribió la IA.

**La decisión de riego siempre sale del motor de reglas del backend**, no del
LLM: `level` y `reason` nunca los cambia la IA. Si el LLM no está disponible,
la respuesta sigue siendo completa.

El backend cachea 10 min; `RecommendationCubit` respeta ese `validUntil` y no
vuelve a pedirla mientras siga vigente.

> `info.imageUrl` puede faltar: el free tier de Perenual devuelve un
> placeholder de paywall para parte del catálogo, y el backend lo descarta. La
> app usa su propio icono en ese caso.

## Clima

`GET /api/weather/forecast?deviceId=:id` trae `isEstimated`. Cuando es `true`
el proveedor externo no respondió y los valores son por defecto (20 °C), no
una medición: la app lo avisa para que no se lea como real.

## Correr el backend en local

Sin PostgreSQL, usando archivos JSON:

```bash
cd ../../Backend/AquaSave-Backend
npm install
npm run dev:local
```

Y la app apuntando ahí:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

Por defecto apunta a `https://aquasave-backend.onrender.com`
(`app_constants.dart`).

> El free tier de Render **duerme por inactividad**: la primera petición puede
> tardar ~30-50 s. Conviene abrir la app unos minutos antes de una demo.

## Pendiente (no bloquea nada)

- Quitar la columna `plant_count` de la base de datos. Hoy queda con default 1.
- Pantalla para que las cuentas con segmento antiguo elijan su nivel. La clave
  de i18n `segmentLegacyPrompt` ya existe; la pantalla no.
