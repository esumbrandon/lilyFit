#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import os

# Change to l10n directory
os.chdir(os.path.dirname(os.path.abspath(__file__)))

def fix_french():
    with open('app_fr.arb', 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixes = {
        "loseWeightDesc": "Créer un déficit calorique",
        "gainWeightDesc": "Développer la masse musculaire",
        "balancedDesc": "Nutrition équilibrée avec tous les groupes alimentaires",
        "highProteinDesc": "Privilégie les protéines pour la croissance et la récupération musculaire",
        "lowCarbKetoDesc": "Réduction des glucides avec des graisses saines plus élevées",
        "vegetarianDesc": "Aliments d'origine végétale avec produits laitiers et œufs autorisés",
        "veganDesc": "100% végétal — aucun produit d'origine animale",
        "macroAnalysisDesc": "Équilibrer parfaitement protéines, glucides et lipides",
        "clearCacheBody": "Cela supprimera les données alimentaires en cache. Vos données personnelles et journaux de repas ne seront pas affectés.",
        "deleteAccountBody": "Cela supprimera définitivement votre compte et toutes les données associées. Cette action ne peut pas être annulée.",
        "resetAllDataBody": "Cela supprimera toutes vos données, y compris les repas, l'historique du poids et le profil. Cette action ne peut pas être annulée.",
        "dataWeCollectBody": "Nous collectons les informations que vous nous fournissez directement, y compris les détails de votre profil (nom, âge, sexe, poids, taille), les préférences alimentaires et les enregistrements de repas. Nous collectons également des données sur votre utilisation de l'application pour améliorer votre expérience.",
        "howWeUseDataBody": "Vos données sont utilisées pour calculer des objectifs caloriques personnalisés, suivre vos progrès et fournir des informations nutritionnelles. Nous ne vendons pas vos informations personnelles à des tiers.",
        "dataStorageBody": "Vos données sont stockées en toute sécurité en utilisant l'infrastructure cloud Supabase avec cryptage. Vous pouvez exporter ou supprimer vos données à tout moment depuis les paramètres de l'application.",
        "yourRightsBody": "Vous avez le droit d'accéder, de modifier ou de supprimer vos données personnelles. Vous pouvez gérer vos données directement dans l'application ou nous contacter pour obtenir de l'aide.",
        "contactUsBody": "Si vous avez des questions sur nos pratiques de confidentialité, veuillez nous contacter à support@lilyfit.app.",
        "acceptanceOfTermsBody": "En utilisant LilyFit, vous acceptez ces conditions d'utilisation. Si vous n'êtes pas d'accord, veuillez ne pas ut iliser l'application.",
        "useOfAppBody": "LilyFit est fourni pour un usage personnel et non commercial. Vous acceptez de ne pas abuser de l'application ou d'interférer avec son fonctionnement.",
        "healthDisclaimerBody": "LilyFit fournit des informations nutritionnelles générales et ne remplace pas les conseils médicaux professionnels. Consultez un professionnel de la santé avant d'apporter des modifications alimentaires importantes.",
        "accountResponsibilityBody": "Vous êtes responsable du maintien de la confidentialité de vos identifiants de compte et de toutes les activités qui se produisent sous votre compte."
    }

    for key, value in fixes.items():
        if key in data:
            data[key] = value

    with open('app_fr.arb', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("✓ French fixed")

def fix_spanish():
    with open('app_es.arb', 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixes = {
        "sedentaryDesc": "Poco o ningún ejercicio",
        "veryActiveDesc": "Trabajo físico + ejercicio",
        "loseWeightDesc": "Crear un déficit calórico",
        "balancedDesc": "Nutrición equilibrada con todos los grupos alimenticios",
        "highProteinDesc": "Prioriza las proteínas para el crecimiento y recuperación muscular",
        "lowCarbKetoDesc": "Carbohidratos reducidos con grasas saludables más altas",
        "vegetarianDesc": "Alimentos de origen vegetal con lácteos y huevos permitidos",
        "calorieTrackingDesc": "Registre comidas y manténgase en el objetivo cada día",
        "macroAnalysisDesc": "Equilibra perfectamente proteínas, carbohidratos y grasas",
        "progressInsightsDesc": "Rastrea tu transformación a lo largo del tiempo",
        "clearCacheBody": "Esto eliminará los datos de alimentos en caché. Sus datos personales y registros de comidas no se verán afectados.",
        "deleteAccountBody": "Esto eliminará permanentemente su cuenta y todos los datos asociados. Esta acción no se puede deshacer.",
        "resetAllDataBody": "Esto eliminará todos sus datos, incluidas las comidas, el historial de peso y el perfil. Esta acción no se puede deshacer.",
        "dataWeCollectBody": "Recopilamos información que nos proporciona directamente, incluidos los detalles de su perfil (nombre, edad, sexo, peso, altura), preferencias dietéticas y registros de comidas. También recopilamos datos sobre el uso de la aplicación para mejorar su experiencia.",
        "howWeUseDataBody": "Sus datos se utilizan para calcular objetivos de calorías personalizados, realizar un seguimiento de su progreso y proporcionar información nutricional. No vendemos su información personal a terceros.",
        "contactUsBody": "Si tiene preguntas sobre nuestras prácticas de privacidad, contáctenos en support@lilyfit.app.",
        "acceptanceOfTermsBody": "Al usar LilyFit, acepta estos términos de servicio. Si no está de acuerdo, no use la aplicación.",
        "healthDisclaimerBody": "LilyFit proporciona información nutricional general y no sustituye el consejo médico profesional. Consulte a un proveedor de atención médica antes de realizar cambios dietéticos significativos.",
        "contactLabelBody": "Para preguntas sobre estos términos, contáctenos en support@lilyfit.app."
    }

    for key, value in fixes.items():
        if key in data:
            data[key] = value

    with open('app_es.arb', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("✓ Spanish fixed")

def fix_german():
    with open('app_de.arb', 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixes = {
        "veryActiveDesc": "Körperliche Arbeit + Bewegung",
        "balancedDesc": "Ausgewogene Ernährung mit allen Lebensmittelgruppen",
        "highProteinDesc": "Priorisiert Protein für Muskelwachstum & Erholung",
        "lowCarbKetoDesc": "Reduzierte Kohlenhydrate mit höheren gesunden Fetten",
        "clearCacheBody": "Dadurch werden zwischengespeicherte Lebensmitteldaten entfernt. Ihre persönlichen Daten und Mahlzeitenprotokolle sind nicht betroffen.",
        "deleteAccountBody": "Dadurch werden Ihr Konto und alle zugehörigen Daten dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.",
        "resetAllDataBody": "Dadurch werden alle Ihre Daten einschließlich Mahlzeiten, Gewichtsverlauf und Profil gelöscht. Dies kann nicht rückgängig gemacht werden.",
        "dataWeCollectBody": "Wir sammeln Informationen, die Sie uns direkt zur Verfügung stellen, einschließlich Ihrer Profildetails (Name, Alter, Geschlecht, Gewicht, Größe), Ernährungspräferenzen und Mahlzeitenprotokolle. Wir sammeln auch Daten über Ihre App-Nutzung, um Ihre Erfahrung zu verbessern.",
        "howWeUseDataBody": "Ihre Daten werden verwendet, um personalisierte Kalorienziele zu berechnen, Ihren Fortschritt zu verfolgen und ernährungswissenschaftliche Erkenntnisse zu liefern. Wir verkaufen Ihre persönlichen Informationen nicht an Dritte.",
        "dataStorageBody": "Ihre Daten werden sicher in der Supabase-Cloud-Infrastruktur mit Verschlüsselung gespeichert. Sie können Ihre Daten jederzeit aus den App-Einstellungen exportieren oder löschen.",
        "yourRightsBody": "Sie haben das Recht, auf Ihre persönlichen Daten zuzugreifen, sie zu ändern oder zu löschen. Sie können Ihre Daten direkt in der App verwalten oder uns um Hilfe bitten.",
        "useOfAppBody": "LilyFit wird für den persönlichen, nicht-kommerziellen Gebrauch bereitgestellt. Sie stimmen zu, die App nicht zu missbrauchen oder ihren Betrieb zu stören.",
        "healthDisclaimerBody": "LilyFit bietet allgemeine ernährungswissenschaftliche Informationen und ist kein Ersatz für professionelle medizinische Beratung. Konsultieren Sie einen Gesundheitsdienstleister, bevor Sie wesentliche Ernährungsumstellungen vornehmen.",
        "accountResponsibilityBody": "Sie sind verantwortlich für die Geheimhaltung Ihrer Kontozugangsdaten und für alle Aktivitäten, die unter Ihrem Konto stattfinden."
    }

    for key, value in fixes.items():
        if key in data:
            data[key] = value

    with open('app_de.arb', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("✓ German fixed")

def fix_portuguese():
    with open('app_pt.arb', 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixes = {
        "sedentaryDesc": "Pouco ou nenhum exercício",
        "lightDesc": "Exercício 1-3 vezes/semana",
        "moderateDesc": "Exercício 3-5 vezes/semana",
        "activeDesc": "Exercício 6-7 vezes/semana",
        "veryActiveDesc": "Trabalho físico + exercício",
        "loseWeightDesc": "Criar um déficit calórico",
        "balancedDesc": "Nutrição equilibrada com todos os grupos alimentares",
        "highProteinDesc": "Prioriza proteínas para crescimento e recuperação muscular",
        "lowCarbKetoDesc": "Carboidratos reduzidos com gorduras saudáveis mais altas",
        "vegetarianDesc": "Alimentos à base de plantas com laticínios e ovos permitidos",
        "calorieTrackingDesc": "Registre refeições e mantenha-se no alvo todos os dias",
        "macroAnalysisDesc": "Balance proteínas, carboidratos e gorduras perfeitamente",
        "progressInsightsDesc": "Acompanhe sua transformação ao longo do tempo",
        "clearCacheBody": "Isso removerá os dados de alimentos em cache. Seus dados pessoais e registros de refeições não serão afetados.",
        "deleteAccountBody": "Isso excluirá permanentemente sua conta e todos os dados associados. Esta ação não pode ser desfeita.",
        "resetAllDataBody": "Isso excluirá todos os seus dados, incluindo refeições, histórico de peso e perfil. Isso não pode ser desfeito.",
        "dataWeCollectBody": "Coletamos informações que você nos fornece diretamente, incluindo detalhes do seu perfil (nome, idade, sexo, peso, altura), preferências alimentares e registros de refeições. Também coletamos dados sobre o uso do aplicativo para melhorar sua experiência.",
        "howWeUseDataBody": "Seus dados são usados para calcular metas de calorias personalizadas, acompanhar seu progresso e fornecer insights nutricionais. Não vendemos suas informações pessoais a terceiros.",
        "dataStorageBody": "Seus dados são armazenados com segurança usando a infraestrutura em nuvem Supabase com criptografia. Você pode exportar ou excluir seus dados a qualquer momento nas configurações do aplicativo.",
        "yourRightsBody": "Você tem o direito de acessar, modificar ou excluir seus dados pessoais. Você pode gerenciar seus dados diretamente no aplicativo ou entrar em contato conosco para obter assistência.",
        "contactUsBody": "Se você tiver dúvidas sobre nossas práticas de privacidade, entre em contato conosco em support@lilyfit.app.",
        "acceptanceOfTermsBody": "Ao usar o LilyFit, você concorda com estes termos de serviço. Se você não concordar, não use o aplicativo.",
        "useOfAppBody": "O LilyFit é fornecido para uso pessoal e não comercial. Você concorda em não fazer uso indevido do aplicativo ou interferir em sua operação.",
        "healthDisclaimerBody": "O LilyFit fornece informações nutricionais gerais e não substitui o aconselhamento médico profissional. Consulte um profissional de saúde antes de fazer mudanças dietéticas significativas.",
        "accountResponsibilityBody": "Você é responsável por manter a confidencialidade das credenciais da sua conta e por todas as atividades que ocorrem sob sua conta.",
        "waterReminderNotificationBody": "Mantenha-se no caminho certo – beba um copo d'água agora."
    }

    for key, value in fixes.items():
        if key in data:
            data[key] = value

    with open('app_pt.arb', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("✓ Portuguese fixed")

if __name__ == '__main__':
    fix_french()
    fix_spanish()
    fix_german()
    fix_portuguese()
    print("\n✅ All encoding issues fixed!")


