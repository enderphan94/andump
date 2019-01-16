# andump
```                                         
               (                         
    )          )\ )   (      )           
 ( /(   (     (()/(  ))\    (     `  )   
 )(_))  )\ )   ((_))/((_)   )\  ' /(/(   
((_)_  _(_/(   _| |(_))(  _((_)) ((_)_\  
/ _` || ' \))/ _` || || || '  \()| '_ \) 
\__,_||_||_| \__,_| \_,_||_|_|_| | .__/  
                                 |_|     
```

For Android Data Forensic

The different data storage options available on Android:

- Internal file storage: Store app-private files on the device file system.
- External file storage: Store files on the shared external file system. This is usually for shared user files, such as photos.
- Shared preferences: Store private primitive data in key-value pairs.
- Databases: Store structured data in a private database.
# Plan

1. Dump data from Sandbox and external enclaves
2. Print all sensitive data along with its file location
3. Based on the rules file, this needs to be updated 

Internal:
1. /data/data

External:
1. /mnt/sdcard/Android/data is a softlink to /sdcard/
2. /


Shared Preferences
SQLite Databases
Realm Databases
Internal Storage
External Storage

# Usage

```./andump.sh -p <packagename>```

Example

For Data Forensic:  ```./andump.sh -p com.google.android```
For Unreliable libraries: ```./andump.sh -l true -d /home/appcode```

## For Unreliable Libraries

#### Overview

There are several ways to persist an object on Android:

##### Object Serialization

An object and its data can be represented as a sequence of bytes. This is done in Java via [object serialization](https://developer.android.com/reference/java/io/Serializable.html "Serializable"). Serialization is not inherently secure. It is just a binary format (or representation) for locally storing data in a .ser file. Encrypting and signing HMAC-serialized data is possible as long as the keys are stored safely. Deserializing an object requires a class of the same version as the class used to serialize the object. After classes have been changed, the `ObjectInputStream` can't create objects from older .ser files. The example below shows how to create a `Serializable` class by implementing the `Serializable` interface.

```java
import java.io.Serializable;

public class Person implements Serializable {
  private String firstName;
  private String lastName;

  public Person(String firstName, String lastName) {
    this.firstName = firstName;
    this.lastName = lastName;
	}
  //..
  //getters, setters, etc
  //..

}

```

Now you can read/write the object with `ObjectInputStream`/`ObjectOutputStream` in another class.

##### JSON

There are several ways to serialize the contents of an object to JSON. Android comes with the `JSONObject` and `JSONArray` classes. A wide variety of libraries, including [GSON](https://github.com/google/gson "Google Gson") or [Jackson](https://github.com/FasterXML/jackson-core "Jackson core"), can also be used. The main differences between the libraries are whether they use reflection to compose the object, whether they support annotations, and the amount of memory they use. Note that almost all the JSON representations are String-based and therefore immutable. This means that any secret stored in JSON will be harder to remove from memory.
JSON itself can be stored anywhere, e.g., a (NoSQL) database or a file. You just need to make sure that any JSON that contains secrets has been appropriately protected (e.g., encrypted/HMACed). See the data storage chapter for more details. A simple example (from the GSON User Guide) of writing and reading JSON with GSON follows. In this example, the contents of an instance of the `BagOfPrimitives` is serialized into JSON:

```java
class BagOfPrimitives {
  private int value1 = 1;
  private String value2 = "abc";
  private transient int value3 = 3;
  BagOfPrimitives() {
    // no-args constructor
  }
}

// Serialization
BagOfPrimitives obj = new BagOfPrimitives();
Gson gson = new Gson();
String json = gson.toJson(obj);  

// ==> json is {"value1":1,"value2":"abc"}

```

##### ORM

There are libraries that provide functionality for directly storing the contents of an object in a database and then instantiating the object with the database contents. This is called Object-Relational Mapping (ORM). Libraries that use the SQLite database include
- [OrmLite](http://ormlite.com/ "OrmLite"),
- [SugarORM](https://satyan.github.io/sugar/ "Sugar ORM"),
- [GreenDAO](http://greenrobot.org/greendao/ "GreenDAO") and
- [ActiveAndroid](http://www.activeandroid.com/ "ActiveAndroid").

[Realm](https://realm.io/docs/java/latest/ "Realm Java"), on the other hand, uses its own database to store the contents of a class. The amount of protection that ORM can provide depends primarily on whether the database is encrypted. See the data storage chapter for more details. The Realm website includes a nice [example of ORM Lite](https://github.com/j256/ormlite-examples/tree/master/android/HelloAndroid "OrmLite example").

##### Parcelable

[`Parcelable`](https://developer.android.com/reference/android/os/Parcelable.html "Parcelable") is an interface for classes whose instances can be written to and restored from a [`Parcel`](https://developer.android.com/reference/android/os/Parcel.html "Parcel"). Parcels are often used to pack a class as part of a `Bundle` for an `Intent`. Here's an Android developer documentation example that implements `Parcelable`:

```java
public class MyParcelable implements Parcelable {
     private int mData;

     public int describeContents() {
         return 0;
     }

     public void writeToParcel(Parcel out, int flags) {
         out.writeInt(mData);
     }

     public static final Parcelable.Creator<MyParcelable> CREATOR
             = new Parcelable.Creator<MyParcelable>() {
         public MyParcelable createFromParcel(Parcel in) {
             return new MyParcelable(in);
         }

         public MyParcelable[] newArray(int size) {
             return new MyParcelable[size];
         }
     };

     private MyParcelable(Parcel in) {
         mData = in.readInt();
     }
 }
```

Because this mechanism that involves Parcels and Intents may change over time, and the `Parcelable` may contain `IBinder` pointers, storing data to disk via `Parcelable` is not recommended.

#### Static Analysis

If object persistence is used for storing sensitive information on the device, first make sure that the information is encrypted and signed/HMACed. See the chapters on data storage and cryptographic management for more details. Next, make sure that the decryption and verification keys are obtainable only after the user has been authenticated. Security checks should be carried out at the correct positions, as defined in [best practices](https://wiki.sei.cmu.edu/confluence/display/java/SER04-J.%20Do%20not%20allow%20serialization%20and%20deserialization%20to%20bypass%20the%20security%20manager "SER04-J. Do not allow serialization and deserialization to bypass the security manager").



There are a few generic remediation steps that you can always take:

1.	Make sure that sensitive data has been encrypted and HMACed/signed after serialization/persistence. Evaluate the signature or HMAC before you use the data. See the chapter about cryptography for more details.
2.	Make sure that the keys used in step 1 can't be extracted easily. The user and/or application instance should be properly authenticated/authorized to obtain the keys. See the data storage chapter for more details.
3.	Make sure that the data within the de-serialized object is carefully validated before it is actively used (e.g., no exploit of business/application logic).

For high-risk applications that focus on availability, we recommend that you use `Serializable` only when the serialized classes are stable. Second, we recommend not using reflection-based persistence because

- the attacker could find the method's signature via the String-based argument
- the attacker might be able to manipulate the reflection-based steps to execute business logic.

See the anti-reverse-engineering chapter for more details.

##### Object Serialization

Search the source code for the following keywords:

-	`import java.io.Serializable`
-	`implements Serializable`

##### JSON

If you need to counter memory-dumping, make sure that very sensitive information is not stored in the JSON format because you can't guarantee prevention of anti-memory dumping techniques with the standard libraries. You can check for the following keywords in the corresponding libraries:

**`JSONObject`** Search the source code for the following keywords:

-	`import org.json.JSONObject;`
-	`import org.json.JSONArray;`

**`GSON`** Search the source code for the following keywords:

-	`import com.google.gson`
-	`import com.google.gson.annotations`
-	`import com.google.gson.reflect`
-	`import com.google.gson.stream`
-	`new Gson();`
-	Annotations such as `@Expose`, `@JsonAdapter`, `@SerializedName`,`@Since`, and `@Until`

**`Jackson`** Search the source code for the following keywords:

-	`import com.fasterxml.jackson.core`
-	`import org.codehaus.jackson` for the older version.

##### ORM

When you use an ORM library, make sure that the data is stored in an encrypted database and the class representations are individually encrypted before storing it. See the chapters on data storage and cryptographic management for more details. You can check for the following keywords in the corresponding libraries:

**`OrmLite`** Search the source code for the following keywords:

- `import com.j256.*`
- `import com.j256.dao`
- `import com.j256.db`
- `import com.j256.stmt`
- `import com.j256.table\`

Please make sure that logging is disabled.

**`SugarORM`** Search the source code for the following keywords:

- `import com.github.satyan`
- `extends SugarRecord<Type>`
- In the AndroidManifest, there will be `meta-data` entries with values such as `DATABASE`, `VERSION`, `QUERY_LOG` and `DOMAIN_PACKAGE_NAME`.

Make sure that `QUERY_LOG` is set to false.

**`GreenDAO`** Search the source code for the following keywords:

-	`import org.greenrobot.greendao.annotation.Convert`
-	`import org.greenrobot.greendao.annotation.Entity`
-	`import org.greenrobot.greendao.annotation.Generated`
-	`import org.greenrobot.greendao.annotation.Id`
-	`import org.greenrobot.greendao.annotation.Index`
-	`import org.greenrobot.greendao.annotation.NotNull`
-	`import org.greenrobot.greendao.annotation.*`
-	`import org.greenrobot.greendao.database.Database`
-	`import org.greenrobot.greendao.query.Query`

**`ActiveAndroid`** Search the source code for the following keywords:

-	`ActiveAndroid.initialize(<contextReference>);`
-	`import com.activeandroid.Configuration`
-	`import com.activeandroid.query.*`

**`Realm`** Search the source code for the following keywords:

-	`import io.realm.RealmObject;`
-	`import io.realm.annotations.PrimaryKey;`

##### Parcelable

Make sure that appropriate security measures are taken when sensitive information is stored in an Intent via a Bundle that contains a Parcelable. Use explicit Intents and verify proper additional security controls when using application-level IPC (e.g., signature verification, intent-permissions, crypto).

# Note
The script is being developed
