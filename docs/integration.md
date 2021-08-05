!!! Warning "Avant-propos"
        Pour comprendre le comment de l'intégration de l'***API de Checkout***, assurez vous de comprendre les notions d'***APIKEY***, ***SITEID*** et d'***url de notification***. Si vous ne comprenez pas ces notions, nous vous recommandons de lire ou relire la page sur l'[API de Checkout](/l'api-de-checkout)

## Mise en route

L'intégration de l'API de Checkout s'inscrit dans le cadre de la mise en place d'un processus automatique d'encaissement de fonds au sein de votre boutique. En fonction du service à délivrer, vous serez amené à personnaliser votre modèle d'intégration pour qu'il corresponde à vos besoins.

!!! Info "Exemple"
        La gestion des paiements sur un site de dons ne sera pas la même que celle d'un site d'e-commerce.  

Peu importe votre situation, vous devrez toujours suivre les étapes suivantes:

1. [Initialisation d'un paiement](#initialisation-d'un-paiement)
2. [Reception des statuts des paiements](#reception-des-status-des-paiements)
3. [Vérification d'un paiement](#verification-d'un-transaction)

Chacune de ces étapes est réalisable à partir d'un endpoint exposé par l'API, sauf pour la reception, qui est une étape qui requiert que vous définissiez votre propre endpoint ([Voir la section sur l'url de notification](#sorry-iam-tired)).

## Initialisation d'un paiement

L'endpoint d'initialisation vous permet de commecer un paimenent par **la génération d'un lien unique vers le guichet de paiement**. 

Il s'agira pour vous d'envoyer une requête de type `POST` au endpoint avec les informations qui caractérisent un paiement, en plus d'une url de notification (`notify_url`) et d'une url de retour (`return_url`) dans le format `JSON`, dans le but de générer un lien vers le guichet de paiement. 

La reponse de cet endpoint contient un token (`payment_token`) et le lien vers le guichet (`payment_url`). Utiliser
ce lien pour rediriger votre client vers le guichet.

<h5>Endpoint</h5>

```
POST https://api-checkout.cinetpay.com/v2/payment
```

| En-tête            | Valeur           |
|--------------------|------------------|
| `Content-Type`     | application/json |

<h5>Paramètres de requête</h5>


| Nom                | Type   | Description                                          |
|--------------------|--------|------------------------------------------------------|
| `apikey`           | string | Votre APIKEY                                         |
| `site_id`          | string | Votre SITEID                                         |
| `transaction_id`   | string | Identifiant du paiement                              |
| `amount`           | int    | Le montant de la transaction                         |
| `currency`         | string | La devise monétaire                                  |
| `description`      | string | Description du paiement en cours                     |
| `customer_name`    | string | Le nom du client                                     |
| `customer_surname` | string | Le prénom du client                                  |
| `notify_url`       | string | Le lien de notification du paiement                  |
| `return_url`       | string | Le lien où le client sera redirigé après le paiement |

<h6>Les devises prises en charges</h6>

| Devise | Pays                                              |
|--------|---------------------------------------------------|
| `XOF`  | Burkina Faso, Côte d'Ivoire, Mali, Togo, Sénégal  |
| `XAF`  | Cameroun                                          |
| `CDF`  | République Démocratique du Congo                  |
| `GBF`  | Guinée                                            |

!!! Question "Retour sur les paramètres `transaction_id` et `return_url`"
        - Le paramètre `transaction_id` doit être unique. En effet, il s'agit de l'identifiant du paiement et sera utilisé  pour retrouver votre paiement. Vous devez le générer vous même, et vous assurer qu'il est unique. Si vous envoyez un identifiant déjà envoyé, alors vous recevrez un message d'erreur en reponse.   

        - Le paramètre `return_url` contient le lien vers la page où le client sera redirigé après le paiement. Ce lien
        est censé pointer sur une page de votre boutique. CinetPay se chargera d'effectuer la rédirection dès la fin d'un paiement en lisant la valeur associé au paramètre. De votre côté vous devez toujours vous assurez que ce lien est fonctionnel.

<h5>Paramètres de reponse</h5>

Vous trouverez dans le tableau ci-dessous l'ensemble des paramètres que peut retourner le endpoint.

| Nom               | Type   | Description                                        |
|-------------------|--------|----------------------------------------------------|
| `code`            | string | Code de la reponse (Voir section sur les codes)    |
| `message`         | string | Message associé à l'erreur                         |
| `description`     | string | Description de l'erreur                            |
| `api_response_id` | string | Identifiant associé à la reponse                   |
| `data`            | json   | Données associées à la reponse                     |
| `payment_token`   | string | Jeton associé au paiement                          |
| `payment_url`     | string | Lien vers le guichet de paiement                   |

!!! Danger "Retour sur le paramètre `payment_token`"
    Vous devez toujours enregistrer le paramètre `payment_token` dans votre base de données. 

<h5>EXEMPLES</h5>

<h6>EXEMPLE DE REQUETE</h6>

=== "curl"

    ``` shell
    curl -X POST https://api-checkout.cinetpay.com/v2/payment \
    -H "Content-Type: application/json" \
    -d '{
            "amount": "2500",
            "apikey": "@mon-aptkey",
            "site_id": "@mon-site-id",
            "currency": "XOF",
            "transaction_id": "@id-de-paiement-hyper-unique",
            "description:" "TRANSACTION DESCRIPTION",
            "return_url:" "https://www.exemple.com/return",
            "notify_url": "https://www.exemple.com/notify",
            "customer_name": "Dje Bi",
            "customer_surname": "Jean-Marc"
        }'
    ```

=== "Powershell"

    ``` powershell

    $Body = @{
            amount = 2500,
            apikey = "@mon-aptkey",
            site_id = "@mon-site-id",
            currency = "XOF",
            transaction_id = "@id-de-paiement-hyper-unique",
            description = "TRANSACTION DESCRIPTION",
            return_url = "https://www.exemple.com/return",
            notify_url = "https://www.exemple.com/notify",
            customer_name = "Dje Bi",
            customer_surname = "Jean-Marc"
    }

    Invoke-RestMethod -Method POST -ContentType "application/json" -Body $body -uri "https://api-checkout.cinetpay.com/v2/payment"
    ```

<h6>EXEMPLE DE REPONSE DE SUCCES</h6>

``` json
{
    "code": "201",
    "message": "CREATED",
    "description": "Transaction created with success",
    "data": {
        "payment_token": "YOUR_TOKEN_HERE",
        "payment_url": "PAYMENT_URL_HERE"
    },
    "api_response_id": "RESPONSE_ID_HERE"
}
```

<h6>EXEMPLE DE REPONSE D'ERREUR</h6>

``` json
{
    "code": "ERROR_CODE",
    "message": "ERROR_MESSAGE ",
    "description": "ERROR_DESCRIPTION",
    "api_response_id": "RESPONSE_ID_HERE"
}
```

---

## Reception des statuts des paiements

Cet endpoint correspond à l'url de notification que vous envoyés (`notify_url`) lors de l'initialisation de vos paiements. CinetPay lui envera via une requête de type `POST` une notification signifiant que votre paiement a changé de statut. Vous devrez alors analyser les paramètres de la requête afin de faire réagir votre système selon votre modèle d'intégration. Notez que les données sont au format `JSON`.

Souvenez vous, la notification ne vous donne pas le statut d'un paiement. Il vaut faudra utiliser l'endpoint de vérification pour avoir le statut ([Voir les references de l'endpoint de vérification](#verification-d'un-paiement)).

!!! Info "Exemple d'un modèle d'intégration d'un site d'e-commerce"
        Le déclenchement du processus de livraison d'une commande d'un client avec une notifcation par mail et par SMS.

<h5>Paramètres d'une notification</h5>

| Nom            | Type   | Description             |
|----------------|--------|-------------------------|
| `cpm_trans_id` | string | Identifiant du paiement |
| `cpm_site_id`  | string | Votre SITEID            |

<h6>EXEMPLE DE PARAMETRE D'UNE NOTIFICATION</h6>

``` json
{
    "cpm_trans_id":"@mon-site-id",
    "cpm_site_id":"@id-de-paiement-hyper-unique"
}
```

Avec ces données vous pourrez vérifier l'état d'un paiement et procéder au post-traitement du paiement selon les recommandations que nous vous avons donné.

!!! Warning "Marquons une pause"
        Avant de continuer, vous êtes priés de relire nos recommandations au sujet des bonnes pratique sur le post-traitement d'un paiement après la reception d'une notification. Nous vous invitons à relire les sections [bon à savoir](/l'api-de-checkout/#bon-a-savoir) et [conseils d'usage](/l'api-de-checkout/#conseils-d'usage).

<h6>EXEMPLE DE POST-TRAITEMENT</h6>

=== "python"

    ```python linenums="1"
    """ Post-traitement d'un site d'e-commerce avec python """

    def postPaymentProcessing(notify_data):
        """ 
            Exemple de code d'un post-traitement.
            notify_data est une distionnaire contenant les données 
            de la notification.
        """

        transaction_id = notify_data["cpm_trans_id"] 
        site_id        = notify_data["cpm_site_id"]

        """
        On suppose que la fonction verifyPaymentStatus 
        appel l'endpoint de vérification pour récupérer le statut
        du paiement
        """
        transaction_status = verifyPaymentStatus(transaction_id, site_id)

        # Lecture du statut du paiement
        trans_status_message = transaction_status["message"]

        if(trans_status_message == "SUCCESS"):
            if(checkIfPaymentIsAlreadySuccess()):
                # La transaction a déjà été mise a jour
                pass
            else:
                # Mise à jour du statut de paiement
                updatePaymentStatus(transaction_id)
                
                # Envoie d'une notification au client par mail
                sendClientSuccessPaymentEmail(transaction_id)

                # Envoie d'une notification au client par SMS
                sendClientSuccessPaymentSMS(transaction_id)

        elif(trans_status == "PAYMENT_FAILED"):
            # Annulation de la commande du client concerné
            cancelClientCommand(transaction_id)
        else:
            # Statut non pris en charge
            pass
    ```
=== "php"

    ``` PHP linenums="1"
    <?php 
        /* Post-traitement d'un site d'e-commerce avec php */
        
        /**
        * Exemple de code d'un post-traitement.
        * notify_data est tableau contenant les données 
        * de la notification.
        */
        function postPaymentProcessing($notify_data):
        
            $transaction_id = $notify_data["cpm_trans_id"]; 
            $site_id        = $notify_data["cpm_site_id"];

            /*
                On suppose que la fonction verifyPaymentStatus 
                appel l'endpoint de vérification pour récupérer le statut
                du paiement
            */
            $transaction_status = verifyPaymentStatus($transaction_id, $site_id);

            // Lecture du statut du paiement
            $trans_status_message = $transaction_status["message"];

            if($trans_status_message == "SUCCESS"){
                if(checkIfPaymentIsAlreadySuccess()){
                    // La transaction a déjà été mise a jour
                }else{
                    // Mise à jour du statut de paiement
                    updatePaymentStatus($transaction_id);
                    
                    // Envoie d'une notification au client par mail
                    sendClientSuccessPaymentEmail($transaction_id);

                    // Envoie d'une notification au client par SMS
                    sendClientSuccessPaymentSMS($transaction_id);
            
            }else if($trans_status == "PAYMENT_FAILED"){
                // Annulation de la commande du client concerné
                cancelClientCommand($transaction_id);
            }else{
                // Statut non pris en charge
            }
    ```

=== "javascript"

    ``` javascript linenums="1"
    /* Post-traitement d'un site d'e-commerce avec php */

    /**
    * Exemple de code d'un post-traitement.
    * notify_data est objet contenant les données 
    * de la notification.
    */
    function postPaymentProcessing(notify_data){
       
        let transaction_id = $notify_data.cpm_trans_id; 
        let site_id        = $notify_data.cpm_site_id;

        /*
            On suppose que la fonction verifyPaymentStatus 
            appel l'endpoint de vérification pour récupérer le statut
            du paiement
        */
        transaction_status = verifyPaymentStatus(transaction_id, site_id);

        // Récupère le statut du paiement
        let trans_status_message = $transaction_status["message"];

        if(trans_status_message == "SUCCESS"){
            if(checkIfPaymentIsAlreadySuccess()){
                // La transaction a déjà été mise a jour
            }else{
                // Mise à jour du statut de paiement
                updatePaymentStatus(transaction_id);
                
                // Envoie d'une notification au client par mail
                sendClientSuccessPaymentEmail(transaction_id);

                // Envoie d'une notification au client par SMS
                sendClientSuccessPaymentSMS(transaction_id);

        }else if(trans_status == "PAYMENT_FAILED"){
            // Annulation de la commande du client concerné
            cancelClientCommand(transaction_id);
        }else{
            // Statut non pris en charge
        }
    }
    ```
!!! Info "Remarque"
        La qualité de votre post-traitement dépendra de la manière dont vous allez implémenter votre propre modèle d'intégration. Notons le rôle de la fonction `verifyPaymentStatus` et la fonction `checkIfPaymentIsAlreadySuccess` qui permettent respectivement de récupérer le statut du paiement et de vérifier si le paiement a déjà été mis à succès.

Retenez que la reception des statuts des paiements vous permet de mettre en place des mecanismes automatiques pour gérer les situations de succès et d'echec de vos paiements après que CinetPay ait fini de les traiter. 

---

## Vérification d'un paiement

Cet endpoint permet de vérifier le statut d'un paiement de façon sécurisé. Pour ce faire il faudra lui envoyer une requête `POST` au format `JSON` avec les données précisées dans le tableau ci-dessous. En reponse vous aurez un `JSON` contenant un message qui caractérise le statut de la transaction.

<h5>Endpoint</h5>

```
POST https://api-checkout.cinetpay.com/v2/payment/check
```

| En-tête            | Valeur           |
|--------------------|------------------|
| `Content-Type`     | application/json |

<h5>Paramètres de requête</h5>

| Nom              | Type   | Description               |
|------------------|--------|---------------------------|
| `apikey`         | string | Votre APIKEY              |
| `site_id`        | string | Votre SITEID              |
| `transaction_id` | string | Identifiant du paiement   |
| `payment_token`  | string | Jeton associé au paiement |

!!! Info "Retour sur les paramètres `transaction_id` et `payment_token`"
    Les paramètres `transaction_id` et `payment_token` permettent tout deux de retouver une transaction. Pour vérifier 
    le statut d'un paiement. Vous n'est pas obligé d'utiliser les deux car un seul suffit pour retrouver un paiement.

<h5>Paramètres d'une reponse</h5>

Vous trouverez dans le tableau ci-dessous l'ensemble des paramètres que peut retourner le endpoint.

| Nom               | Type   | Description                                               |
|-------------------|--------|-----------------------------------------------------------|
| `code`            | string | Code de reponse                                           |
| `message`         | string | Statut du paiement                                        |
| `api_response_id` | string | Identifiant du paiement                                   |
| `data`            | json   | Données associées à la reponse                            |
| `operator_id`     | string | Identifiant de l'opérateur                                |
| `payment_method`  | string | Nom de la méthode utilisé pour effectuer le paiement      |
| `phone_number`    | string | Numéro de téléphone                                       |
| `phone_prefix`    | string | Préfixe du numéro de téléhpone                            |

<h5>EXEMPLES</h5>

<h6>EXEMPLE DE REQUETE</h6>

=== "curl"

    ``` shell
    curl -X POST https://api-checkout.cinetpay.com/v2/payment/check \
    -H "Content-Type: application/json" \
    -d '{
            "apikey": "@mon-aptkey",
            "site_id": "@id-de-paiement-hyper-unique",
            "transaction_id": "@mon-site-id",
        }'
    ```

=== "Powershell"

    ``` powershell

    $Body = @{
            apikey = "@mon-aptkey",
            site_id = "@mon-site-id",
            transaction_id = "@id-de-paiement-hyper-unique",
    }

    Invoke-RestMethod -Method POST -ContentType "application/json" -Body $body -uri "https://api-checkout.cinetpay.com/v2/payment/check"
    ```

<h6>EXEMPLE DE REPONSE DE SUCCES</h6>

``` json hl_lines="3"
{
    "code": "00",
    "message": "SUCCES",
    "api_response_id": "1617808789.7749",
    "data": {
        "operator_id": "8210407187720",
        "payment_method": "FLOOZ",
        "payment_date": "2021-04-07 14:07:24",
        "phone_number": "0102324373",
        "phone_prefix": "225"
    }
}   
```
<h6>EXEMPLE DE REPONSE D'ECHEC</h6>

``` json hl_lines="3"
{
"code": "600",
"message": "PAYMENT_FAILED",
"api_response_id": "1617808521.2503",
    "data": {
    "payment_method": "OM",
    "payment_date": "2021-04-07 15:07:24",
    "phone_number": "0749012966",
    "phone_prefix": "225"
    }
}
```

<h6>EXEMPLE DE FONCTION DE VERIFICATION</h6>

=== "python"

    ```python linenums="1"
    import requests

    API_KEY = "@mon-aptkey"
    SITE_ID = "@mon-site-id"
    URL = "https://api-checkout.cinetpay.com/v2/payment/check"

    def verifyPaymentStatus(transaction_id, site_id):

        headers = {"Content-Type": "application/json}

        data = {
            "apikey": API_KEY,
            "site_id": SITE_ID,
            "transaction_id": transaction_id
        }

        r = requests.post(url = URL, headers=headers, data = data)

        return r.json()
    ```
=== "php"

    ``` PHP linenums="1"
    <?php 
        use GuzzleHttp\Client;

        define("API_KEY","@mon-aptkey")
        define("SITE_ID","@mon-site-id")
        define("URL","https://api-checkout.cinetpay.com/v2/payment/check")

        function verifyPaymentStatus($transaction_id, $site_id){

            $data = [
                "apikey" => API_KEY,
                "site_id" => SITE_ID,
                "transaction_id" => $transaction_id
            ];

            $option = [
                'headers' => [
                    'Content-Type' => 'application/json'
                ],
                'form_params' => $data
            ];

            $request = new Client();
            
            $response = $request->post(URL, $option);

            return $response->getBody();

        }
    ```

=== "javascript"

    ``` javascript linenums="1"
    const axios = require("axios");

    const API_KEY = "@mon-aptkey";
    const SITE_ID = "@mon-site-id";
    const URL = "https://api-checkout.cinetpay.com/v2/payment/check";

    function verifyPaymentStatus(notify_data){
        
        let data = {
            "apikey": API_KEY,
            "site_id": SITE_ID,
            "transaction_id": transaction_id
        };

        let config = {
            headers: {'Content-Type': 'application/json'}
        }

        status = null;

        // Voir https://github.com/axios/axio pour une meilleur comprehension
        return axios.post(URL,data,config);

    }

    ```
---

## Conclusion

A ce stade vous disposez de toutes les informations nécessaires pour réussir votre intégration. Il vous revient maintenant de mettre en pratique vos nouvelles connaissance dans l'implémentation de votre modèle d'intégration. 

Au cas où vous ne savez pas quoi faire ou rencontrez des difficultés de compréhension, n'hésitez pas à contactez notre support. Néanmoins nous vous recommandons de relire cette documentation jusqu'à la maitriser sur le bout des doigts car c'est forgeant qu'on devient forgeron. A bientôt  !

Adresse du support: [support@cinetpay.com](mailto:support@cinetpay.com)

*Dernière mise à jour le 02/08/2021 par Jean-Marc Dje Bi*