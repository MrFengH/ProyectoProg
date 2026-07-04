<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mahmoud Parfums</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">
</head>
<body>
    
    <header>
        <nav>
            <div class="logo">
                <a href="">
                    <img src="assets/logo.png">
                </a>
                <a href=""><h2>ESSENCE</h2></a>
            </div>
            <div class="nav-links">
                <a href="index.html">Inicio</a>
                <a href="productos.html">Colección</a>
                <a href="">Sobre Nosotros</a>
                <a href="">Carrito</a>
            </div>
            <div class="top-icons">
                <a href="https://www.google.com" aria-label="Buscar en Google">
                    <img src="assets/lupa.png" alt="Buscar" class="search-icon">
                </a>
                <a href="https://www.instagram.com" aria-label="Instagram">IG</a>
                <a href="https://www.facebook.com" aria-label="Facebook">F</a>
                <a href="https://www.x.com" aria-label="X">X</a>
            </div>
            <div class="perfil">
                <img src="assets/IconoPerfil.png" alt="Icono de perfil">
                <div class="perfil-info">
                    <h4>Usuario</h4>
                    <a href="login.html">Iniciar Sesión</a>
                </div>
            </div>
        </nav>

        <section class="hero">
            <div class="hero-content">
                <div class="tag">
                    Essence boutique olfativa
                </div>

                <h1>Fragancias premium para cada ocasión</h1>

                <p>
                    Descubre perfumes de autor con notas intensas, elegantes y duraderas, creados para dejar una presencia memorable.
                </p>

                <p style="color: #ffffffc7;">
                    Una seleccion exclusiva de aromas amaderados, florales y orientales con acabados sofisticados para el dia, la noche y momentos especiales.
                </p>

            </div>
        </section>
    </header>

    <main>
        <section class="coleccion" id="coleccion">
            <div class="section-title">
                <span>Coleccion exclusiva</span>
                <h2>Colección</h2>
                <p>Perfumes seleccionados para quienes buscan elegancia, presencia y una identidad olfativa memorable.</p>
            </div>

            <div class="cards-coleccion">
                <article class="card-perfume">
                    <img src="assets/LogoPerfume.png" alt="Perfume Noir Essence">
                    <div class="card-info">
                        <h3>Noir Essence</h3>
                        <p>Notas de vainilla negra, madera de cedro y ambar dorado para una presencia intensa.</p>
                        <div class="card-compra">
                            <p class="precio">$89.99</p>
                            <button type="button">Comprar</button>
                        </div>
                    </div>
                </article>

                <article class="card-perfume">
                    <img src="assets/LogoPerfume1.png" alt="Perfume Gold Atelier">
                    <div class="card-info">
                        <h3>Gold Atelier</h3>
                        <p>Una fragancia sofisticada con jazmín, bergamota y almizcle suave para ocasiones especiales.</p>
                        <div class="card-compra">
                            <p class="precio">$94.99</p>
                            <button type="button">Comprar</button>
                        </div>
                    </div>
                </article>

                <article class="card-perfume">
                    <img src="assets/LogoPerfume (1).png" alt="Perfume Black Velvet">
                    <div class="card-info">
                        <h3>Black Velvet</h3>
                        <p>Aroma envolvente de cuero fino, especias calidas y flores nocturnas con acabado elegante.</p>
                        <div class="card-compra">
                            <p class="precio">$99.99</p>
                            <button type="button">Comprar</button>
                        </div>
                    </div>
                </article>
            </div>
        </section>

        <section class="news">
            <div class="section-title">
                <span>Novedades del Mundo de la Perfumería</span>
                <h2>Noticias</h2>
                <p>Tendencias, lanzamientos y recomendaciones del universo de la Perfumería</p>
            </div>
            <div class="news-collection">
                <article class="news-cards">
                    <img src="assets/prada-infusion-iris.jpg" alt="Prada Infusion d'Iris">
                    <div class="news-info">
                        <span>Mejores perfumes 2026</span>
                        <h3>Infusion d'Iris de Prada, entre los mejores perfumes de mujer de 2026</h3>
                        <p>Trendencias incluye a Infusion d'Iris de Prada en su listado de los mejores perfumes de mujer de 2026: una fragancia floral amaderada que combina lirio, musgos y cítricos en un aroma envolvente que se funde con la piel.</p>
                        <a href="https://www.trendencias.com/belleza/32-mejores-perfumes-para-mujer-2026-huelen-espectacular-no-pasan-desapercibidos" target="_blank" rel="noopener">Leer artículo -></a>
                    </div>
                </article>

                <article class="news-cards">
                    <img src="assets/banner1.jpg" alt="Molecule 01 + Champaca de Escentric Molecules">
                    <div class="news-info">
                        <span>Tendencias 2026</span>
                        <h3>Los 7 perfumes que marcan 2026, según Marie Claire</h3>
                        <p>Marie Claire repasa las fragancias más destacadas del año, entre ellas Molecule 01 + Champaca de Escentric Molecules, fiel al sello aéreo y amaderado del iso e super.</p>
                        <a href="https://www.marie-claire.es/belleza/mejores-perfumes-nuevos-2026.html" target="_blank" rel="noopener">Leer artículo -></a>
                    </div>
                </article>

                <article class="news-cards">
                    <img src="assets/banner-perfumes-negros-elegantes.png" alt="Anuncio de Bleu de Chanel con Timothée Chalamet">
                    <div class="news-info">
                        <span>Video</span>
                        <h3>Timothée Chalamet protagoniza el nuevo anuncio de Bleu de Chanel</h3>
                        <p>Chanel estrena en su canal oficial de YouTube la campaña de Bleu de Chanel protagonizada por el actor Timothée Chalamet.</p>
                        <a href="https://www.youtube.com/watch?v=OYR3VhXp8ZY" target="_blank" rel="noopener">Ver video -></a>
                    </div>
                </article>
            </div>
        </section>

    </main>

    <footer class="footer">
        <div class="footer-menu">
            <a href="index.html">Inicio</a>
            <a href="index.html#coleccion">Colección</a>
            <a href="contacto.html">Sobre Nosotros</a>
            <a href="login.html">Logout</a>
        </div>
        <p>&copy; 2026 ESSENCE. Todos los derechos reservados.</p>
    </footer>
</body>
</html>
