local rate = sdk.get_managed_singleton("app.VariousDataManager")._Setting._RandomAmuletGradeTable._Values:get_Item(0)._Rate
rate:set_Item(0, 50)
rate:set_Item(1, 20)
rate:set_Item(2, 10)
rate:set_Item(3, 20)