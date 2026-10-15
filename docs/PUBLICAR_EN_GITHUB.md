# Publicar la versión integrada en GitHub Pages

El repositorio de Miguel es [migusaper1530/app-grafos](https://github.com/migusaper1530/app-grafos).
El enlace de la app es [migusaper1530.github.io/app-grafos](https://migusaper1530.github.io/app-grafos/).
El remoto `origin` se conserva apuntando a ese repositorio.

El código integrado está en la rama `merge-shell-sort`. El workflow publica
cuando se actualiza `main`. La integración incorpora el historial remoto de
`main`, de forma que ambas ramas pueden avanzar sin reescribir commits.

## Probar la app localmente

Desde la carpeta del proyecto:

```bash
flutter pub get
flutter run -d chrome
```

Cierra la ejecución anterior antes de iniciar esta versión. La estructura de
las pantallas cambió; una ejecución nueva carga los módulos reorganizados.

## Subir la integración y actualizar la web

La integración ya queda guardada en un commit. Ejecuta:

```bash
cd "/home/miguel/Documents/universidad/Analisis de algoritmos/app-grafos/app-grafos"
git fetch origin
git switch merge-shell-sort
git push -u origin merge-shell-sort
git switch main
git pull --ff-only origin main
git merge --ff-only merge-shell-sort
git push origin main
```

Los avances son normales (`fast-forward`): estos comandos no utilizan `--force`.
Si Git informa que el remoto avanzó de nuevo y rechaza la operación, conserva
el mensaje y revisa esos nuevos cambios antes de continuar.

La autenticación para el push corresponde a tu cuenta de GitHub. No escribas
tokens en archivos del proyecto ni los incluyas en los commits.

## Comprobar GitHub Pages

1. Abre [Actions](https://github.com/migusaper1530/app-grafos/actions).
2. Espera a que **Publicar LogiVerse en GitHub Pages** termine en verde.
3. Abre [la app](https://migusaper1530.github.io/app-grafos/).
4. Si el navegador mantiene una versión anterior, usa `Ctrl+Shift+R`.

En **Settings → Pages → Build and deployment → Source** debe estar seleccionado
**GitHub Actions**, igual que en la publicación anterior. También puedes iniciar
el workflow desde **Actions → Publicar LogiVerse en GitHub Pages → Run workflow → main**.

## Qué hace el workflow

`.github/workflows/deploy-pages.yml` usa Flutter 3.47.7, ejecuta el análisis y
las pruebas, obtiene la ruta base del propio repositorio, compila Flutter Web y
publica únicamente `build/web`. Así los recursos se resuelven bajo `/app-grafos/`
y la configuración no depende de la cuenta o el repositorio de tu compañero.
Los archivos generados no se guardan en Git.

## Referencias oficiales

- [Workflows personalizados para Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
- [Configurar la fuente de publicación](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
- [Compilar y publicar Flutter Web](https://docs.flutter.dev/deployment/web)
