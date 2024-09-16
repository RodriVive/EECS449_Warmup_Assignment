from __future__ import annotations
from jaclang.plugin.feature import JacFeature as _Jac
from jaclang.plugin.builtin import *
from dataclasses import dataclass as __jac_dataclass__

@_Jac.make_walker(on_entry=[_Jac.DSFunc('return_message', _Jac.RootType)], on_exit=[])
@__jac_dataclass__(eq=False)
class interact(_Jac.Walker):

    def return_message(self, _jac_here_: _Jac.RootType) -> None:
        _Jac.report({'response': 'Hello, world!'})

@_Jac.make_walker(on_entry=[_Jac.DSFunc('return_message', _Jac.RootType)], on_exit=[])
@__jac_dataclass__(eq=False)
class interact_with_body(_Jac.Walker):
    name: str

    def return_message(self, _jac_here_: _Jac.RootType) -> None:
        _Jac.report({'response': 'Hello, ' + self.name + '!'})

@_Jac.make_walker(on_entry=[_Jac.DSFunc('return_message', _Jac.RootType)], on_exit=[])
@__jac_dataclass__(eq=False)
class get_update(_Jac.Walker):
    type: str

    def return_message(self, _jac_here_: _Jac.RootType) -> None:
        if self.type == 'weather':
            _Jac.report({'response': 'It is sunny!'})
        elif self.type == 'date':
            _Jac.report({'response': 'It is Sunday!'})

@_Jac.make_walker(on_entry=[_Jac.DSFunc('return_message', _Jac.RootType)], on_exit=[])
@__jac_dataclass__(eq=False)
class tell_me_something(_Jac.Walker):
    type: str

    def return_message(self, _jac_here_: _Jac.RootType) -> None:
        if self.type == 'fact':
            _Jac.report({'response': 'The first computer was invented by Charles Babbage (1822) but was not built until 1991!'})
        elif self.type == 'joke':
            _Jac.report({'response': 'I would tell you a UDP joke, but you might not get it.'})