# View & Event

`View`和`Event`都在<u>应用初始化</u>阶段定义。

## View

当您希望程序外部的用户（非参与者）了解程序的当前值时，您可以使用视图 `View` 。 

例如，NFT 程序会将当前所有者公开为视图 `View` 。

### View定义

有2种形式来定义 `view` ，下面是2个简单的例子：

```js
View('NFT', { owner: Address })
// 或者
View({ owner: Address })
```

视图(View)由 `View(viewName, viewInterface)` 或 `View(viewInterface)` 定义，其中 `viewName` 是一个标记 `View` 的字符串（起个名字），`viewInterface` 是一个对象，其中的每个字段是相关的合约提供的函数或值。

这些视图可通过 `ctc.views` 对象在前端使用。

在 DApp 中，此应用程序参数的结果称为 `View` 对象。

### View对象

如果 `View` 是一个视图对象，那么它的字段就是相关视图的元素。

这些字段中的每一个都使用 `set` 方法绑定到一个对象，该方法接受要在当前步骤绑定到该视图的函数或值，以及由当前步骤控制的所有步骤（除非另有覆盖）。

如果这个函数没有提供参数，那么对应的视图是未设置的。

### 示例

```

```



##  Event

当您希望程序外部的用户（非参与者）了解程序的历史时，您可以使用事件 `Event` 。

 例如，NFT 程序可以在每次所有者更改时发出一个事件，外部用户可以看到所有权变更的历史。

### Event定义

有2种形式来定义 `Event` ：

```js
Events('Logger', {
    log: [UInt, Byte(64)]
})
// 或者
Events({
    log: [UInt, Byte(64)]
})
```

事件(Event)由 `Events(eventName, eventInterface)` 或 `Events(eventInterface)` 定义，其中 `eventName` 是一个标记事件的字符串（起个名字），而 `eventInterface` 是一个对象，其中每个字段都是一个 `Tuple` 类型，表示事件将发出的值的类型。

这些事件通过 `ctc.events` 对象在前端可用。

在 DApp 中，此应用程序参数的结果称为 `Event` 对象。

### Event对象

```js
Logger.log(4, x);
```

如果 `Event` 是一个事件对象，那么它的字段就是相关事件的元素。这些字段中的每一个都是一个函数，其域由事件接口指定。

### 示例

```

```







