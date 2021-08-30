!!! Warning "Avant-propos"
        Assurez vous de comprendre les notions d'***APIKEY***, ***SITEID*** et d'***url de notification***. Si vous ne comprenez pas ces notions, nous vous recommandons de lire ou relire la page sur l'[API de Checkout](/l'api-de-checkout)

## Mise en route

L'intégration de l'API de Checkout s'inscrit dans le cadre de la mise en place d'un processus automatique d'encaissement de fonds au sein de votre boutique. En fonction du service à délivrer, vous serez amené à personnaliser votre modèle d'intégration pour qu'il corresponde à vos besoins.

!!! Info "Exemple de modèles d'integration"
        La gestion des paiements sur un site de dons et la gestion des commandes d'un site d'e-commerce.

        -  Un site de dons n'a pas forcement besoin de traiter les succès ou les echecs des paiements puisqu'aucun service n'est delivré

        - Un site d'e-commerce doit tenir compte du succès ou de l'echec d'un paiement pour valider ou invalider une commande

Peu importe votre situation, vous devrez toujours veiller à suivre les étapes suivantes:

1. [Initialisation d'un paiement](#initialisation-d'un-paiement)
2. [Reception des statuts des paiements](#reception-des-status-des-paiements)
3. [Vérification d'un paiement](#verification-d'un-transaction)

Les étapes est réalisable à partir d'endpoints exposé par l'API, sauf pour la reception, qui est une étape qui requiert que vous définissiez votre propre endpoint ([Voir la section sur l'url de notification](/l%27api-de-checkout/#la-notification)).

## Initialisation d'un paiement

Dans l'intégration l'endpoint d'initialisation vous permet de commencer un paimenent par **la génération d'un lien unique vers le guichet de paiement**. 

Il s'agira pour vous d'envoyer une requête de type `POST` au endpoint avec les informations qui caractérisent un paiement, en plus d'une url de notification (`notify_url`) et d'une url de retour (`return_url`). 

L'objectif est de générer un lien vers le guichet de paiement. 
Pour initialiser un paiement vous devez **générer un lien unique vers le guichet de paiement** en envoyant une requête de type `POST` au endpoint, avec les informations caractérisant le paiement, en plus d'une url de notification (`notify_url`) et d'une url de retour (`return_url`). L'objectif est de générer un lien vers le guichet de paiement. 

La reponse de cet endpoint contient en particulier un token (`payment_token`) et le lien vers le guichet (`payment_url`). Utiliser
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
| `GNF`  | Guinée                                            |

!!! Question "Retour sur les paramètres `transaction_id` et `return_url`"
        - Le paramètre `transaction_id` doit être unique. En effet, il s'agit de l'identifiant du paiement du côté de votre boutique. Vous devez le générer vous même, et vous assurer qu'il soit unique. Si vous envoyez un identifiant déjà envoyé, alors vous recevrez un message d'erreur en reponse.   

        - Le paramètre `return_url` contient le lien vers la page où le client sera redirigé après le paiement. Ce lien
        est censé pointer sur une page de votre boutique. CinetPay se chargera d'effectuer la rédirection dès la fin d'un paiement par la lecture de la valeur associé au paramètre. De votre côté vous devez toujours vous assurez que ce lien est fonctionnel.

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

    ``` sh
    curl -X POST https://api-checkout.cinetpay.com/v2/payment \
    -H "Content-Type: application/json" \
    -d '{
            "amount": 100,
            "apikey": "votre-apikey",
            "site_id": "votre-site-id",
            "currency": "XOF",
            "transaction_id": "id-de-paiement-unique",
            "description": "TRANSACTION DESCRIPTION",
            "return_url": "https://www.exemple.com/return",
            "notify_url": "https://www.exemple.com/notify",
            "customer_name": "Dje Bi",
            "customer_surname": "Jean-Marc"
        }'
    ```

=== "python"

    ``` python
    import requests

    API_KEY = "votre-apikey"

    SITE_ID = "votre-site-id"

    URL = "https://api-checkout.cinetpay.com/v2/payment"

    headers = {
        "Content-Type": "application/json"
    }

    payment = {
        "amount": 100,
        "apikey": API_KEY,
        "site_id": SITE_ID,
        "currency": "XOF",
        "transaction_id": "id-de-paiement-unique",
        "description": "TRANSACTION DESCRIPTION",
        "return_url": "https://www.exemple.com/return",
        "notify_url": "https://www.exemple.com/notify",
        "customer_name": "Dje Bi",
        "customer_surname": "Jean-Marc"
        
    }

    response = requests.post(url=URL, headers=headers, json=payment)

    print(response)
    ```

=== "javascript"

    ``` javascript
    const axios = require("axios");

    let API_KEY = "votre-apikey";

    let SITE_ID = "votre-site-id";

    let URL = "https://api-checkout.cinetpay.com/v2/payment";

    let CONFIG = {
        headers: {'Content-Type': 'application/json'}
    }

    let payment = {
        "amount": 100,
        "apikey": API_KEY,
        "site_id": SITE_ID,
        "currency": "XOF",
        "transaction_id": "id-de-paiement-unique",
        "description": "TRANSACTION DESCRIPTION",
        "return_url": "https://www.exemple.com/return",
        "notify_url": "https://www.exemple.com/notify",
        "customer_name": "Dje Bi",
        "customer_surname": "Jean-Marc"    
    }

    axios.post(URL,payment,CONFIG)
        .then(function(api_response){

            let response = api_response.data;

            console.log(response);

        })
        .catch(function(error){

            console.log(error.message);

        });
    ```

=== "java"

    ``` java
    public class InitPayment {
	
        public static void main(String[] args) throws IOException, InterruptedException {
        
            String API_KEY = "votre-apikey"; 
            
            String SITE_ID = "votre-site-id";
            
            String URL = "https://api-checkout.cinetpay.com/v2/payment";
            
            String payment = String.format("{\r\n"
                    + "        \"amount\": 100,\r\n"
                    + "        \"apikey\":  \"%s\",\r\n"
                    + "        \"site_id\": \"%s\",\r\n"
                    + "        \"currency\": \"XOF\",\r\n"
                    + "        \"transaction_id\": \"id-de-paiement-unique\",\r\n"
                    + "        \"description\": \"TRANSACTION DESCRIPTION\",\r\n"
                    + "        \"return_url\": \"https://www.exemple.com/return\",\r\n"
                    + "        \"notify_url\": \"https://www.exemple.com/notify\",\r\n"
                    + "        \"customer_name\": \"Dje Bi\",\r\n"
                    + "        \"customer_surname\": \"Jean-Marc\"\r\n"
                    + "        \r\n"
                    + "    }",API_KEY,SITE_ID);
                        
            BodyPublisher requestBody = HttpRequest.BodyPublishers.ofString(payment);
            
            try {
                
                HttpRequest request = HttpRequest.newBuilder()
                        .uri(new URI(URL))
                        .header("Content-Type","application/json")
                        .POST(requestBody)
                        .build();
                
                HttpResponse<String> response = HttpClient.newHttpClient().send(request, BodyHandlers.ofString());
                
                System.out.println(response.body());
                
            } catch (URISyntaxException e) {

                e.printStackTrace();
                
            }
          
        }
    }
    ```

=== "C#"

    ``` c#
    public class InitPayment {

        public async void initPayment(){

            string API_KEY = "votre-apikey"; 
            
            string SITE_ID = "votre-site-id";
            
            string URL = "https://api-checkout.cinetpay.com/v2/payment";

            var payment = new 
            {
                amount = 100,
                apikey = API_KEY,
                site_id = SITE_ID,
                currency = "XOF",
                transaction_id = "id-de-paiement",
                description = "TRANSACTION DESCRIPTION",
                return_url = "https://www.exemple.com/return",
                notify_url = "https://www.exemple.com/notify",
                customer_name = "Dje Bi",
                customer_surname = "Jean-Marc"
            };

            string json = JsonConvert.SerializeObject(payment);

            StringContent data = new StringContent(json, Encoding.UTF8, "application/json");

            var client = new HttpClient();

            var response = await client.PostAsync(url, data);

            string result = await response.Content.ReadAsStringAsync();

            Console.WriteLine(result);
            
        }

    }
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

La reception des statuts des paiements est effectuée par l'endpoint correspondant à l'url de notification que vous envoyés (`notify_url`) lors de l'initialisation de vos paiements. CinetPay lui enverra via une requête de type `POST` une notification signifiant que votre paiement a changé de statut. Vous devrez alors analyser les paramètres de la requête afin de faire réagir votre système selon votre modèle d'intégration.

Souvenez vous, la notification ne vous donne pas le statut d'un paiement. Il vaut faudra utiliser l'endpoint de vérification pour avoir le statut ([Voir les references de l'endpoint de vérification](#verification-d'un-paiement)).

!!! Info "Exemple d'un modèle d'intégration d'un site d'e-commerce"
        Le déclenchement du processus de livraison d'une commande d'un client suivi d'une notifcation par mail et par SMS.

<h5>Paramètres d'une notification</h5>

| Nom            | Type   | Description             |
|----------------|--------|-------------------------|
| `cpm_trans_id` | string | Identifiant du paiement |
| `cpm_site_id`  | string | Votre SITEID            |

<h6>EXEMPLE DE PARAMETRE D'UNE NOTIFICATION</h6>

``` json
{
    "cpm_trans_id":"id-de-paiement",
    "cpm_site_id":"votre-site-id"
}
```

Avec ces données vous pourrez vérifier l'état d'un paiement et procéder au post-traitement du paiement selon les recommandations donné au niveau des sections sur les bonnes pratiques.

!!! Warning "Marquons une pause"
        Avant de continuer, vous êtes priés de relire nos recommandations au sujet des bonnes pratique sur le post-traitement d'un paiement après la reception d'une notification. Nous vous invitons à relire les sections [bon à savoir](/l'api-de-checkout/#bon-a-savoir) et [conseils d'usage](/l'api-de-checkout/#conseils-d'usage).

<h6>EXEMPLE DE POST-TRAITEMENT</h6>

!!! Info "Remarque"
    L'exemple qui suit est un squelette d'implementations d'un post-traitement dans un site d'e-commerce dans different langages. Il n'est qu'à titre illustratif et vous pouvez vous en inspirer pour definir votre post-traitement.

=== "python"

    ```python linenums="1"
    """ Post-traitement d'un site d'e-commerce avec python """

    def postPaymentProcessing(notify_data):
        """ 
            Exemple de code d'un post-traitement.
            notify_data est une distionnaire contenant les données 
            de la notification.
        """

        # 0. La fonction est appelée lors de la reception d'un statut final par le developpeur

        transaction_id = notify_data["cpm_trans_id"] 
        site_id        = notify_data["cpm_site_id"]

        # 1. Recuperation du statut final de la transaction

        """
        On suppose que la fonction verifyPaymentStatus 
        appel l'endpoint de vérification pour récupérer le statut
        du paiement
        """
        transaction_status = verifyPaymentStatus(transaction_id, site_id)

        # 2. Lecture du statut du paiement
        trans_status_message = transaction_status["message"]

        # 3. Analyse du statut final

        if(trans_status_message == "SUCCESS"): # En cas de succès

            # 4. Vérifier si le paiement est deja a success

            """
            On suppose que la fonction checkIfPaymentIsAlreadySuccess 
            permet de vérifier que le paiement est déjà à succès dans la base de données des paiments du site
            """

            if(checkIfPaymentIsAlreadySuccess(transaction_id)):

                # La transaction a déjà été mise à jour

                pass

            else:
                # 5. Mettre à jour le statut de paiement

                # 6. Envoyer une notification au client par mail

                # 7. Envoyer une notification au client par mail

                pass

        elif(trans_status == "PAYMENT_FAILED" or trans_status == "INSUFFISENT_BALANCE"): # En cas d'echec

            # Annulation de la commande du client concerné

            pass

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

            // 0. La fonction est appelée lors de la reception d'un statut final par le developpeur
        
            $transaction_id = $notify_data["cpm_trans_id"]; 
            $site_id        = $notify_data["cpm_site_id"];

            // 1. Recuperation du statut final de la transaction

            /*
                On suppose que la fonction verifyPaymentStatus 
                appel l'endpoint de vérification pour récupérer le statut
                du paiement
            */
            $transaction_status = verifyPaymentStatus($transaction_id, $site_id);

            // 2. Lecture du statut du paiement
            $trans_status_message = $transaction_status["message"];

            // 3. Analyse du statut final

            if($trans_status_message == "SUCCESS"){ // En cas de succès

                // 4. Vérifier si le paiement est déjà a success

                /*
                    On suppose que la fonction checkIfPaymentIsAlreadySuccess 
                    permet de vérifier que le paiement est déjà à succès dans la base de données des paiments du site
                */

                if(checkIfPaymentIsAlreadySuccess(transaction_id)){

                    // La transaction a déjà été mise à jour
                    
                }else{

                    // 5. Mettre à jour le statut de paiement

                    // 6. Envoyer une notification au client par mail

                    // 7. Envoyer une notification au client par mail

                }
            }else if($trans_status == "PAYMENT_FAILED" || $trans_status == "INSUFFISENT_BALANCE"){

                // Annulation de la commande du client concerné

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

        // 0. La fonction est appelée lors de la reception d'un statut final par le developpeur
       
        let transaction_id = notify_data.cpm_trans_id; 
        let site_id        = notify_data.cpm_site_id;

        // 1. Recuperation du statut final de la transaction

        /*
            On suppose que la fonction verifyPaymentStatus 
            appel l'endpoint de vérification pour récupérer le statut
            du paiement
        */
        transaction_status = verifyPaymentStatus(transaction_id, site_id);

        // 2. Lecture du statut du paiement
        let trans_status_message = transaction_status.message;

        // 3. Analyse du statut final

        if(trans_status_message == "SUCCESS"){ // En cas de succès
            
            // 4. Vérifier si le paiement est deja a success

            /*
                On suppose que la fonction checkIfPaymentIsAlreadySuccess 
                permet de vérifier que le paiement est déjà à succès dans la base de données des paiments du site
            */

            if(checkIfPaymentIsAlreadySuccess()){

                // La transaction a déjà été mise à jour

            }else{

                // 5. Mettre à jour le statut de paiement

                // 6. Envoyer une notification au client par mail

                // 7. Envoyer une notification au client par mail

        }else if(trans_status == "PAYMENT_FAILED" || trans_status == "INSUFFISENT_BALANCE"){

            // Annulation de la commande du client concerné

        }else{

            // Statut non pris en charge

        }
    }
    ```

=== "java"

    ``` java linenums="1"
    /** 
     * Post-traitement d'un site d'e-commerce avec php 
     */

    class PostPayment{

        /**
        * Exemple de code d'un post-traitement.
        * notify_data est objet contenant les données 
        * de la notification.
        */
        public void postPaymentProcessing(HashMap<String,String> notify_data){

            // 0. La fonction est appelée lors de la reception d'un statut final par le developpeur
        
            String transaction_id = notify_data.get("cpm_trans_id"); 
            String site_id        = notify_data.get("cpm_site_id");

            // 1. Recuperation du statut final de la transaction

            /*
                On suppose que la fonction verifyPaymentStatus 
                appel l'endpoint de vérification pour récupérer le statut
                du paiement
            */
            HashMap<String,String> transaction_status = verifyPaymentStatus(transaction_id, site_id);

            // 2. Lecture du statut du paiement
            String trans_status_message = transaction_status.get("message");

            // 3. Analyse du statut final

            if(trans_status_message.equals("SUCCESS")){ // En cas de succès
                
                // 4. Vérifier si le paiement est déjà à success

                /*
                    On suppose que la fonction checkIfPaymentIsAlreadySuccess 
                    permet de vérifier que le paiement est déjà à succès dans la base de données des paiments du site
                */

                if(checkIfPaymentIsAlreadySuccess()){

                    // La transaction a déjà été mise a jour

                }else{

                    // 5. Mettre à jour le statut de paiement

                    // 6. Envoyer une notification au client par mail

                    // 7. Envoyer une notification au client par mail

            }else if(trans_status.equals("PAYMENT_FAILED") || trans_status.equals("INSUFFISENT_BALANCE")){

                // Annulation de la commande du client concerné

            }else{

                // Statut non pris en charge

            }
        }
    }
    ```

=== "C#"

    ``` c# linenums="1"
    /** 
     * Post-traitement d'un site d'e-commerce avec php 
     */

    class PostPayment{

        /**
        * Exemple de code d'un post-traitement.
        * notify_data est objet contenant les données 
        * de la notification.
        */
        public void postPaymentProcessing(var notify_data){

            // 0. La fonction est appelée lors de la reception d'un statut final par le developpeur
        
            string transaction_id = notify_data.cpm_trans_id; 
            string site_id        = notify_data.cpm_site_id;

            // 1. Recuperation du statut final de la transaction

            /*
                On suppose que la fonction verifyPaymentStatus 
                appel l'endpoint de vérification pour récupérer le statut
                du paiement
            */
            var transaction_status = verifyPaymentStatus(transaction_id, site_id);

            // 2. Lecture du statut du paiement
            string trans_status_message = transaction_status.message;

            // 3. Analyse du statut final

            if(string.Equals(trans_status_message,"SUCCESS") || string.Equals(trans_status_message,"INSUFFISENT_BALANCE")){ // En cas de succès
                
                // 4. Vérifier si le paiement est déjà à success

                /*
                    On suppose que la fonction checkIfPaymentIsAlreadySuccess 
                    permet de vérifier que le paiement est déjà à succès dans la base de données des paiments du site
                */

                if(checkIfPaymentIsAlreadySuccess()){

                    // La transaction a déjà été mise a jour

                }else{

                    // 5. Mettre à jour le statut de paiement

                    // 6. Envoyer une notification au client par mail

                    // 7. Envoyer une notification au client par mail

            }else if(string.Equals(trans_status_message,"PAYMENT_FAILED")){

                // Annulation de la commande du client concerné

            }else{

                // Statut non pris en charge

            }
        }
    }
    ```
!!! Info "Remarque"
        La qualité de votre post-traitement dépendra de la manière dont vous allez implémenter votre propre modèle d'intégration. Notons le rôle de la fonction `verifyPaymentStatus` et la fonction `checkIfPaymentIsAlreadySuccess` qui permettent respectivement de récupérer le statut du paiement et de vérifier si le paiement a déjà été mis à succès.

Retenez que la reception des statuts des paiements vous permet de mettre en place des mecanismes automatiques pour gérer les situations de succès et d'echec de vos paiements après que CinetPay ait fini de les traiter. 

---

## Vérification d'un paiement

Cet endpoint permet de vérifier le statut d'un paiement de façon sécurisé. Pour ce faire il faudra lui envoyer une requête `POST` avec les données précisées dans le tableau ci-dessous. En reponse vous aurez un `JSON` contenant un message qui caractérise le statut de la transaction.

<h5>Endpoint</h5>

```
POST https://api-checkout.cinetpay.com/v2/payment/check
```

| En-tête            | Valeur           |
|--------------------|------------------|
| `Content-Type`     | application/json |

<h5>Paramètres de requête</h5>

| Nom                               | Type   | Description               |
|-----------------------------------|--------|---------------------------|
| `apikey`                          | string | Votre APIKEY              |
| `site_id`                         | string | Votre SITEID              |
| `transaction_id`                  | string | Identifiant du paiement   |
| `payment_token` (Peut être omis)  | string | Jeton associé au paiement |

!!! Info "Retour sur les paramètres `transaction_id` et `payment_token`"
    Les paramètres `transaction_id` et `payment_token` permettent tout deux de retrouver une transaction. Pour vérifier 
    le statut d'un paiement. Vous n'êtes pas obligés d'utiliser les deux car un seul suffit pour retrouver un paiement.

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

Les valeurs prises par le propriété `message` sont les suivantes:

| Valeur                                      | Code   |
|---------------------------------------------|--------|
| `SUCCES`                                    | `00`   |
| `PAYMENT_FAILED`                            | `600`  |
| `INSUFFISENT_BALANCE`                       | `602`  |
| `SERVICE_UNAVAILABLE`                       | `603`  |
| `OTP_CODE_ERROR`                            | `604`  |
| `WAITING_CUSTOMER_TO_VALIDATE`              | `623`  |
| `TRANSACTION_CANCEL `                       | `627`  |
| `ERROR_PHONE_NUMBER_NOT_FOUND`              | `635`  |
| `ERROR_PHONE_NUMBER_NOT_SUPPORTED`          | `636`  |
| `ERROR_AMOUNT_TOO_LOW`                      | `641`  |
| `ERROR_AMOUNT_TOO_HIGH`                     | `642`  |
| `WAITING_CUSTOMER_PAYMENT`                  | `662`  |
| `WAITING_CUSTOMER_OTP_CODE`                 | `663`  |
| `WAITING_CUSTOMER_PAYMENT_AT_OPERATOR_SIDE` | `664`  |
| `OPERATOR_UNAVAILABLE`                      | `804`  |
| `DAILY_MAX_NUMBER_TRANSACTION_REACHED`      | `807`  |
| `DAILY_MAX_AMOUNT_TRANSACTION_REACHED`      | `808`  |
| `MONTHLY_MAX_AMOUNT_TRANSACTION_REACHED`    | `809`  |
| `MONTHLY_MAX_NUMBER_TRANSACTION_REACHED`    | `810`  |
| `WEEKLY_MAX_AMOUNT_TRANSACTION_REACHED`     | `811`  |
| `WEEKLY_MAX_NUMBER_TRANSACTION_REACHED`     | `812`  |
| `INCORRECT_SETTINGS`                        | `606`  |



<h5>EXEMPLES</h5>

<h6>EXEMPLE DE REQUETE</h6>



=== "curl"

    ``` shell
    curl -X POST https://api-checkout.cinetpay.com/v2/payment/check \
    -H "Content-Type: application/json" \
    -d '{
            "apikey": "votre-aptkey",
            "site_id": "votre-site-id",
            "transaction_id": "id-de-paiement",
        }'
    ```

=== "python"

    ``` python
    import requests

    API_KEY = "votre-apikey"

    SITE_ID = "votre-site-id"

    URL = "https://api-checkout.cinetpay.com/v2/payment/check"

    headers = {
        "Content-Type": "application/json"
    }

    payment = {
        "apikey": API_KEY,
        "site_id": SITE_ID,
        "transaction_id": "id-de-paiement"
    }

    response = requests.post(url=URL, headers=headers, json=payment)

    print(response)
    ```

=== "javascript"

    ``` javascript
    const axios = require("axios");

    let API_KEY = "votre-apikey";

    let SITE_ID = "votre-site-id";

    let URL = "https://api-checkout.cinetpay.com/v2/payment/check";

    let CONFIG = {
        headers: {'Content-Type': 'application/json'}
    }

    let payment = {
        "apikey": API_KEY,
        "site_id": SITE_ID,
        "transaction_id": "id-de-paiement", 
    }

    axios.post(URL,payment,CONFIG)
        .then(function(api_response){

            let response = api_response.data;

            console.log(response);

        })
        .catch(function(error){

            console.log(error.message);

        });
    ```

=== "java"

    ``` java
    public class InitPayment {
	
        public static void main(String[] args) throws IOException, InterruptedException {
        
            String API_KEY = "votre-apikey"; 
            
            String SITE_ID = "votre-site-id";
            
            String URL = "https://api-checkout.cinetpay.com/v2/payment/check";
            
            String payment = String.format("{\r\n"
                    + "        \"apikey\":  \"%s\",\r\n"
                    + "        \"site_id\": \"%s\",\r\n"
                    + "        \"transaction_id\": \"id-de-paiement\",\r\n"
                    + "        \r\n"
                    + "    }",API_KEY,SITE_ID);
                        
            BodyPublisher requestBody = HttpRequest.BodyPublishers.ofString(payment);
            
            try {
                
                HttpRequest request = HttpRequest.newBuilder()
                        .uri(new URI(URL))
                        .header("Content-Type","application/json")
                        .POST(requestBody)
                        .build();
                
                HttpResponse<String> response = HttpClient.newHttpClient().send(request, BodyHandlers.ofString());
                
                System.out.println(response.body());
                
            } catch (URISyntaxException e) {

                e.printStackTrace();
                
            }
          
        }
    }
    ```

=== "C#"

    ``` c#
    public class InitPayment {

        public async void initPayment(){

            string API_KEY = "votre-apikey"; 
            
            string SITE_ID = "votre-site-id";
            
            string URL = "https://api-checkout.cinetpay.com/v2/payment/check";

            var payment = new 
            {
                apikey = API_KEY,
                site_id = SITE_ID,
                transaction_id = "id-de-paiement",
            };

            string json = JsonConvert.SerializeObject(payment);

            StringContent data = new StringContent(json, Encoding.UTF8, "application/json");

            var client = new HttpClient();

            var response = await client.PostAsync(url, data);

            string result = await response.Content.ReadAsStringAsync();

            Console.WriteLine(result);
            
        }

    }
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

---

## Conclusion

A ce stade vous disposez de toutes les informations nécessaires pour réussir votre intégration. Il vous revient maintenant de mettre en pratique vos nouvelles connaissance dans l'implémentation de votre modèle d'intégration. 

Au cas où vous ne savez pas quoi faire ou rencontrez des difficultés de compréhension, n'hésitez pas à contactez notre support. Néanmoins nous vous recommandons de relire cette documentation jusqu'à la maitriser sur le bout des doigts.

Adresse du support: [support@cinetpay.com](mailto:support@cinetpay.com)

*Dernière mise à jour le 24/08/2021 par Jean-Marc Dje Bi*